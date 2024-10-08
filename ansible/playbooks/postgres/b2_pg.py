#!/usr/bin/env python3
from custom_logger import CustomLogger
import logging
import os
from dotenv import load_dotenv
from b2sdk.v2 import B2Api
from b2sdk.v2 import InMemoryAccountInfo
from datetime import datetime

class B2SyncJob:
    def __init__(self, dotenv_path='.env', log_file='b2copy.log', debug=False):
        self.dotenv_path = dotenv_path
        self.log_file = log_file
        self.debug = debug

        if self.debug:
            self.log_level = logging.DEBUG
        else:
            self.log_level = logging.INFO

        logger = CustomLogger(name='B2SyncJob', log_file='b2_sync.log', log_level=self.log_level)

        logger.info("Configuring b2-sdk to store credentials in memory")
        info = InMemoryAccountInfo()
        b2_api = B2Api(info)

        logger.info("loading b2 application key from envfile: {}".format(self.dotenv_path))
        load_dotenv(dotenv_path=self.dotenv_path)
        B2_KEY_ID = os.getenv('B2_APPLICATION_KEY_ID')
        B2_SECRET = os.getenv('B2_APPLICATION_KEY')
        
        if len(B2_KEY_ID) == 0  
            raise Exception("B2_APPLICATION_KEY_ID is empty")
        elif len(B2_SECRET) == 0:
            raise Exception("B2_APPLICATION_KEY is empty")
        try:
            logger.info("Authorizing B2 Account with the supplied Key")
            b2_api.authorize_account("production", B2_KEY_ID, B2_SECRET)
        except:
            logger.error("Failed to authorize B2 account with the supplied Key and Secret")
            logger.error("Please verify B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY are set correctly in {}".format(self.dotenv_path))
