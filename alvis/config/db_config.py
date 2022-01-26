# pylint: disable=no-name-in-module
from pydantic import BaseSettings, PostgresDsn


class DBSettings(BaseSettings):
    pg_dsn: PostgresDsn

    class Config:  # noqa: D106
        env_file = ".env"


db_settings = DBSettings()  # type: ignore
