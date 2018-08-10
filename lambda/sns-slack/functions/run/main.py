import os
import engine
import boto3
import logging
import json

e = engine.Engine(
    webhook_url=os.environ['SLACK_URL'],
    channel=os.environ['SLACK_CHANNEL'],
    channel2=os.environ['SLACK_CHANNEL2'],
    channel_fallback=os.environ['SLACK_CHANNEL_FALLBACK'],
)

def handle(event, context):
    print(json.dumps(event))
    e.handle(event)

if __name__ == '__main__':
    handle({}, None)
