import asyncclick as click

from .data_ingest.ingest import ingest_data_pipeline


@click.group()
def cli():
    """Terminal UI helpers."""


@cli.command()
@click.option("--csv_url", help="URL of csv file to download.")
@click.option("--csv_file", help="Name of csv file.")
@click.option("--table_name", help="Name of DB table to insert data.")
@click.option("--convert_datetime", help="Convert datetime fields in yellow data.", is_flag=True)
async def ingest_data(csv_url: str, csv_file: str, table_name: str, convert_datetime: bool):
    """Download csv file and insert into Prostgres DB.

    Args:
        csv_url (str): URL of csv file to download.
        csv_file (str): Name of csv file.
        table_name (str): Name of DB table to insert data.
        convert_datetime (bool): Convert datetime fields in yellow data.
    """
    await ingest_data_pipeline(csv_url, csv_file, table_name, convert_datetime)
