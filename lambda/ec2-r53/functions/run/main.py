import os
import engine
import boto3
import logging

ptr_zones = []
for part in os.environ.get('EC2R53_ZONE_PTR', '').split(','):
    if len(part) == 0:
        continue
    prefix_zone = part.split(':')
    if len(prefix_zone) != 2:
        continue
    ptr_zones.append({'prefix': prefix_zone[0] + '.', 'zone': prefix_zone[1]})

zone = os.environ['EC2R53_ZONE']
domain = os.environ['EC2R53_DOMAIN']
shorthand_domain = os.environ.get('EC2R53_SHORTHAND_DOMAIN', None)
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-1')

vpc_tag = os.environ.get('EC2R53_VPC_TAG', 'Name')
default_to_amazon_name = os.environ.get('EC2R53_AMAZON_NAME', '1') == '1'

boto3.set_stream_logger('', logging.INFO)
a = engine.AwsAdapter(region=aws_region, vpc_dns_name_tag=vpc_tag)
e = engine.Engine(adapter=a, domain=domain, zone=zone, ptr_zones=ptr_zones, default_to_amazon_name=default_to_amazon_name, shorthand_domain=shorthand_domain)


def handle(event, context):
    print('id:%s eventid:%s' % (event.get('id'), event['detail'].get('eventID')))
    e.handle(event)

if __name__ == '__main__':
    handle({}, None)
