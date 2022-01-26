import pathlib

import asyncclick as click
import httpx
from tqdm import tqdm


def overwrite_file_prompt(file_path: pathlib.Path) -> bool:
    """Get user input if given file exists.

    Args:
        file_path (pathlib.Path): File path.

    Returns:
        bool: Overwrite file input.
    """
    click.echo(click.style(f"A file named {file_path.name} already exists", fg="yellow", bold=True))
    click.confirm(click.style("Do you want to continue?", fg="cyan"), abort=True, default=True)
    return click.confirm(click.style(f"Would you like to overwrite {file_path.name}?", fg="cyan"))


async def download_file(file_path: pathlib.Path, url: str) -> None:
    """Download file from URL.

    Args:
        file_path (pathlib.Path): Path to save file.
        url (str): URL to download file from.
    """
    client = httpx.AsyncClient()

    with file_path.open("wb") as file:
        async with client.stream("GET", url) as response:
            total = int(response.headers["Content-Length"])

            with tqdm(total=total, unit_scale=True, unit_divisor=1024, unit="B") as progress:
                num_bytes_downloaded = response.num_bytes_downloaded
                async for chunk in response.aiter_bytes():
                    file.write(chunk)
                    progress.update(response.num_bytes_downloaded - num_bytes_downloaded)
                    num_bytes_downloaded = response.num_bytes_downloaded

    await client.aclose()


async def download_pipeline(file_path: pathlib.Path, url: str) -> None:
    """Download file from URL and save to given location. Allows user to overwrite if file exists.

    Args:
        file_path (pathlib.Path): Path to file.
        url (str): URL to download file from.

    Returns:
        None
    """
    if file_path.is_file():
        if overwrite_file_prompt(file_path=file_path):
            return await download_file(file_path=file_path, url=url)
        return
    return await download_file(file_path=file_path, url=url)
