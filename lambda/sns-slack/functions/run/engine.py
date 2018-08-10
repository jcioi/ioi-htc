import boto3
import botocore
import json
from botocore.vendored import requests

from codepipeline_handler import CodePipelineHandler
from fallback_handler import FallbackHandler

#from sns_handler_proxy import SnsHandlerProxy


class Engine():
    def __init__(self, webhook_url, channel, channel2, channel_fallback):
        self.webhook_url = webhook_url
        self.channel = channel
        self.channel2 = channel2
        self.channel_fallback = channel_fallback

    def handle(self, event):
        handlers = [
                CodePipelineHandler,
        ]

        do_fallback = True
        payloads = []
        for handler_class in handlers:
            handler = handler_class(event, channel=self.channel, channel2=self.channel2)
            if handler.supports():
                payloads.extend(handler.payloads())
                do_fallback = False
        if do_fallback:
            payloads.extend(FallbackHandler(event, channel=self.channel_fallback).payloads())

        for payload in payloads:
            self.post(payload)

    def post(self, payload):
        print(payload)
        requests.post(self.webhook_url, json=payload)
