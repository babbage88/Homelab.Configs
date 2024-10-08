#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
import sys
from custom_logger import CustomLogger
import logging
import os
from dotenv import load_dotenv
from b2sdk.v2 import B2Api, InMemoryAccountInfo, ScanPoliciesManager,  Synchronizer, SyncReport
from b2sdk.v2 import KeepOrDeleteMode, CompareVersionMode, NewerFileSyncMode
from b2sdk.v2 import parse_folder
from datetime import datetime
import time
import argparse
import argcomplete

class B2SyncJob:
    def __init__(self, dotenv_path='.env', log_file='b2copy.log', debug=False, local_file_path=None, b2_bucket_name='trahan-postgres-backups'):
        self.dotenv_path = dotenv_path
        self.log_file = log_file
        self.debug = debug
        self.local_file_path = local_file_path
        self.b2_bucket_name = b2_bucket_name
        self.b2_bucket_url = 'b2://' + self.b2_bucket_name

        if self.debug:
            self.log_level = logging.DEBUG
        else:
            self.log_level = logging.INFO

        self.logger = CustomLogger(name='B2SyncJob', log_file='b2_sync.log', log_level=self.log_level)

        self.logger.info("Configuring b2-sdk to store credentials in memory")
        info = InMemoryAccountInfo()
        self.b2_api = B2Api(info)

        self.logger.info("loading b2 application key from envfile: {}".format(self.dotenv_path))
        load_dotenv(dotenv_path=self.dotenv_path)
        B2_KEY_ID = os.getenv('B2_APPLICATION_KEY_ID')
        B2_SECRET = os.getenv('B2_APPLICATION_KEY')

        if len(B2_KEY_ID) == 0:
            raise Exception("B2_APPLICATION_KEY_ID is empty")
        elif len(B2_SECRET) == 0:
            raise Exception("B2_APPLICATION_KEY is empty")
        try:
            self.logger.info("Authorizing B2 Account with the supplied Key")
            self.b2_api.authorize_account("production", B2_KEY_ID, B2_SECRET)
        except:
            self.logger.error("Failed to authorize B2 account with the supplied Key and Secret")
            self.logger.error("Please verify B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY are set correctly in {}".format(self.dotenv_path))

    def syncronize(self, src=None, dst=None):
        if src != None:
            source = src
        else:
            source = self.local_file_path

        if dst != None:
            destination = dst
        else:
            destination = self.b2_bucket_url

        self.logger.info("Parsing source {} for files to sync.".format(source))
        source = parse_folder(source, self.b2_api)
        self.logger.info("Pasing destination: {} to compare to source".format(destination))
        destination = parse_folder(destination, self.b2_api)
        policies_manager = ScanPoliciesManager(exclude_all_symlinks=True)

        synchronizer = Synchronizer(
            max_workers=10,
            policies_manager=policies_manager,
            dry_run=False,
            allow_empty_source=True,
            compare_version_mode=CompareVersionMode.MODTIME,
            compare_threshold=10,
            newer_file_mode=NewerFileSyncMode.REPLACE,
            keep_days_or_delete=KeepOrDeleteMode.KEEP_BEFORE_DELETE,
            keep_days=30,
        )

        self.logger.info("Starting B2 Synchronizor source: {} destination: {}".format(source, destination))
        with SyncReport(sys.stdout) as reporter:
            synchronizer.sync_folders(
                source_folder=source,
                dest_folder=destination,
                now_millis=int(round(time.time() * 1000)),
                reporter=reporter,
                )

if __name__=="main":
    parser = argparse.ArgumentParser(description="Test CustomLogger with arguments.")
    parser.add_argument("--envfile", type=str, default=".env", help=".env file for B2 authentication")
    parser.add_argument("--log-file", type=str, default="b2copy.log", help="Log file to write to")
    parser.add_argument("--local-path", type=str, default="/pgdumps/backups", help="Path of local files")
    parser.add_argument("--bucket-name", type=str, default="trahan-postgres-backups", help="B2 bucket name")
    parser.add_argument("--sync-src", type=str, default=None, help="Coustom Source path for syncronize job")
    parser.add_argument("--sync-dst", type=str, default=None, help="Coustom Source path for syncronize job")
    parser.add_argument("--debug", type=bool, action=argparse.BooleanOptionalAction, help="Enable Debug logging")
    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    b2_job = B2SyncJob(dotenv_path=args.envfile, log_file=args.log_file, debug=args.debug, local_file_path=args.local_path, b2_bucket_name=args.bucket_name)
    b2_job.syncronize()
