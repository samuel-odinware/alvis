"""Pytest configuration."""

from typing import Generator

import logging

import pytest
from loguru import logger


@pytest.fixture
def caplog(
    capture_log: pytest.LogCaptureFixture,
) -> Generator[pytest.LogCaptureFixture, None, None]:
    """Override caplog to use logger.

    Args:
        capture_log (pytest.LogCaptureFixture): Pytest caplog.

    Yields:
        capture_log: Pytest caplog using logger.
    """
    logger.remove()  # remove default handler, if it exists
    logger.enable("")  # enable all logs from all modules
    logging.addLevelName(5, "TRACE")  # tell python logging how to interpret TRACE logs

    class PropagateHandler(logging.Handler):
        """Propagate log record to logger."""

        def emit(self, record: logging.LogRecord) -> None:
            logging.getLogger(record.name).handle(record)

    logger.add(
        PropagateHandler(), format="{message} {extra}", level="TRACE"
    )  # shunt logs into the standard python logging machinery
    capture_log.set_level(0)  # Tell logging to handle all log levels
    yield capture_log
