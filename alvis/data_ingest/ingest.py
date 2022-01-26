import pathlib
from time import time

import asyncclick as click
import pandas as pd
from sqlalchemy import create_engine

from ..config import db_settings
from .downloader import download_pipeline


def downloads_directory_path() -> pathlib.Path:
    """Resolve downloads directory path.

    Returns:
        pathlib.Path: Path to downloads directory.
    """
    downloads_dir = pathlib.Path.cwd() / "downloads"
    if not downloads_dir.exists():
        downloads_dir.mkdir(exist_ok=True, parents=True)
    return downloads_dir


def read_csv(file_path: pathlib.Path) -> pd.DataFrame:
    """Read csv file to Pandas iterable DataFrame.

    Args:
        file_path (pathlib.Path): Path of csv file.

    Returns:
        pd.DataFrame: Iterable DataFrame.
    """
    return pd.read_csv(file_path, iterator=True, chunksize=100_000)  # type: ignore


def insert_dataframe_in_db(
    iterable_df: pd.DataFrame, table_name: str, convert_datetime: bool
) -> None:
    """Insert DataFrame into SQL database.

    Args:
        iterable_df (pd.DataFrame): Iterable DataFrame
        table_name (str): Name of table to insert data into.
        convert_datetime (bool): Convert columns to datetime. This is a hack for now.
    """
    engine = create_engine(db_settings.pg_dsn)

    for idx, df_chunk in enumerate(iterable_df):
        # Silly hack for now
        if convert_datetime:
            df_chunk.tpep_pickup_datetime = pd.to_datetime(df_chunk.tpep_pickup_datetime)
            df_chunk.tpep_dropoff_datetime = pd.to_datetime(df_chunk.tpep_dropoff_datetime)

        if idx == 0:
            df_chunk.head(n=0).to_sql(name=table_name, con=engine, if_exists="replace")
        t_start = time()

        df_chunk.to_sql(name=table_name, con=engine, if_exists="append")

        t_end = time()

        click.echo(f"Inserted chunk {idx + 1} in {table_name} ({t_end - t_start:.3f} seconds.)")


async def ingest_data_pipeline(
    csv_url: str, csv_file: str, table_name: str, convert_datetime: bool
):
    """Pipeline to download and insert csv data in SQL database.

    Args:
        csv_url (str): URL of csv file.
        csv_file (str): Name of csv file.
        table_name (str): Name of table to insert data.
        convert_datetime (bool): Option to convert columns to datetime.
    """
    csv_path = downloads_directory_path().joinpath(csv_file)
    await download_pipeline(csv_path, csv_url)
    df_iter = read_csv(csv_path)
    insert_dataframe_in_db(df_iter, table_name, convert_datetime)
