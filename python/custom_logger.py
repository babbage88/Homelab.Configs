#!/usr/bin/env python3
import logging
import argparse

class CustomFormatter(logging.Formatter):
    # Define color codes for log levels with bold and underline
    bright_white = "\x1b[1;97m" 
    bright_magenta = "\x1b[1;95m"   
    bright_green = "\x1b[1;92m"
    bright_yellow = "\x1b[1;93m"
    bright_red = "\x1b[1;91m"
    ul_bright_white = "\x1b[1;4;97m"
    ul_bright_magenta = "\x1b[1;4;95m"
    ul_bright_green = "\x1b[1;4;92m"
    ul_bright_yellow = "\x1b[1;4;93m"
    ul_bright_red = "\x1b[1;4;31m"
    blinking_critical_red = "\x1b[1;4;5;91m"
    reset = "\x1b[0m"

    # Log format string
    format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)"
    
    # Map log levels to their respective format strings
    FORMATS = {
        logging.DEBUG: bright_white + format + reset,
        logging.INFO: bright_green + format + reset,
        logging.WARNING: bright_yellow + format + reset,
        logging.ERROR: bright_red + format + reset,
        logging.CRITICAL: blinking_critical_red + format + reset
    }

    def format(self, record):
        # Retrieve the format based on the log level
        log_fmt = self.FORMATS.get(record.levelno, self.format)
        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)

# CustomLogger class to use the CustomFormatter
class CustomLogger:
    def __init__(self, name: str, log_file: str = None, log_level: int = logging.DEBUG):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(log_level)

        if not self.logger.hasHandlers():
            self._setup_handlers(log_file, log_level)

    def _setup_handlers(self, log_file, log_level):
        # Console Handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(log_level)
        console_handler.setFormatter(CustomFormatter())  # Use custom formatter
        self.logger.addHandler(console_handler)

        # File Handler if log_file is provided
        if log_file:
            file_handler = logging.FileHandler(log_file)
            file_handler.setLevel(log_level)
            # Use a simple format for the file log
            file_formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)")
            file_handler.setFormatter(file_formatter)
            self.logger.addHandler(file_handler)

    def get_logger(self):
        return self.logger

def test_logger(name='TrahanLogger', log_file='app.log', log_level=logging.DEBUG):
    logger = CustomLogger(name=name, log_file=log_file, log_level=log_level).get_logger()

    logger.debug("This is a debug message")
    logger.info("This is an info message")
    logger.warning("This is a warning message")
    logger.error("This is an error message")
    logger.critical("This is a critical message")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test CustomLogger with arguments.")
    parser.add_argument("--name", type=str, default="TrahanLogger", help="Name of the logger")
    parser.add_argument("--log_file", type=str, default="app.log", help="Log file to write to")
    parser.add_argument("--log_level", type=str, default="DEBUG", help="Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)")
    
    args = parser.parse_args()

    # Convert log level string to corresponding logging level constant
    log_level = getattr(logging, args.log_level.upper(), logging.DEBUG)

    # Call the test_logger function with parsed arguments
    test_logger(name=args.name, log_file=args.log_file, log_level=log_level)
