# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/test/test_julia.py
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
import logging

import pytest

LOGGER = logging.getLogger(__name__)


def test_octave(container):
    """Basic octave test"""
    LOGGER.info(f"Test that octave is correctly installed ...")
    running_container = container.run(
        tty=True, command=["start.sh", "bash", "-c", "sleep infinity"]
    )
    command = f"octave --version"
    cmd = running_container.exec_run(command)
    output = cmd.output.decode("utf-8")
    assert cmd.exit_code == 0, f"Command {command} failed {output}"
    LOGGER.debug(output)
