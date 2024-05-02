import logging


def log_info(msg):
    print(f"\033[92m[INFO] {msg}\033[0m")
    logging.info(msg)


def log_warning(msg):
    print(f"\033[93m[WARNING] {msg}\033[0m")
    logging.warning(msg)


def log_error(msg):
    print(f"\033[91m[ERROR] {msg}\033[0m")
    logging.error(msg)


def log_critical(msg):
    print(f"\033[95m[CRITICAL] {msg}\033[0m")
    logging.critical(msg)


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
