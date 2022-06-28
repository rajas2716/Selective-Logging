#!/usr/env/bin python
import logging
import time

from hdinsight_common import utilities
from hdinsight_common import hdinsightlogging

logger = logging.getLogger(__name__)


def restart_service(service):
    exitcode, out, err = utilities.execute_command_with_return_code(["systemctl", "restart", service], False, False, True)
    if exitcode != 0:
        raise RuntimeError("restarting service {}  failed with stdout {} and stderr {}".format(service,out, err))
    logger.info("restarting service {}  succeeded".format(service))
    return

def serivce_is_active(service):
    exitcode, out, err = utilities.execute_command_with_return_code(["systemctl", "is-active", "--quiet", service], False, False, True)
    if exitcode != 0:
        logger.info("service {}  is not active".format(service))
        return False
    logger.info("service {}  is active".format(service))
    return True

def kill_process(pid):
    exitcode, out, err = utilities.execute_command_with_return_code(["sudo", "kill", "-9", pid], False, False, True)
    if exitcode != 0:
        raise RuntimeError("killing process  {}  failed with stdout {} and stderr {}".format(pid, out, err))
    logger.info("successfully killed process {}".format(pid))
    return

def ensure_mdsd_restarted():
    mdsd_successful_start = False
    retries = 0
    while not mdsd_successful_start and retries < 5:
        mdsd_pid = find_mdsd_pid()
        if mdsd_pid > 0:
            kill_process(mdsd_pid)
        time.sleep(5*(retries + 1))
        mdsd_successful_start = (not pidport_error_exists() and serivce_is_active("mdsd"))
        retries += 1
    if retries == 5:
        raise RuntimeError("mdsd restart is failing")
    return


def pidport_error_exists():
    exitcode, out, err = utilities.execute_command_with_return_code(
        ["tail", "-1", "/var/log/mdsd.err"], False, False, True)
    if exitcode != 0:
        raise RuntimeError(
            "tailing mdsd err file failed with  stdout {} and stderr {}".format(out, err))

    if out == MDSD_PIDPORT_ERROR:
        logger.info("found pidport error")
        return True
    else:
        logger.info("no pidport error")
        return False

def find_mdsd_pid():
    exitcode, out, err = utilities.execute_command_with_return_code(["pidof", "-s", "mdsd"], False, False, True)
    if exitcode != 0:
        return -1
    mdsd_pid = str(int(out))
    logger.info("found mdsd process with pid {0}".format(mdsd_pid))
    return mdsd_pid

MDSD_PIDPORT_ERROR = "Error: unexpected exception while starting listeners: LockedFile::Open() : File '/var/run/mdsd/default.pidport' is already locked"
