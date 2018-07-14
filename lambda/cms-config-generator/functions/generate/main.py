import re
import boto3
import json

ec2 = boto3.client('ec2', 'ap-northeast-1')
s3 = boto3.client('s3', 'ap-northeast-1')

service_name_to_port = {
  'LogService':      29000,
  'ResourceService': 28000,
  'ScoringService':  28500,
  'Checker':         22000,
  'EvaluationService': 25000,
  'Worker':            26000,
  'ContestWebServer':  21000,
  'AdminWebServer':    21100,
  'ProxyService':      28600,
  'PrintingService':   25123,
}

s3_bucket = 'ioi18-infra'
s3_key_regexp = re.compile('\Acms/(.+?)/base\.json')

def find_tag(key, tags, default=None):
    return next((tag['Value'] for tag in tags if tag['Key'] == key), default)

def generate_ec2_services(cluster):
    services = {}

    pager = ec2.get_paginator('describe_instances').paginate(Filters=[{'Name': 'tag:CmsCluster', 'Values': [cluster]}])
    for r in pager.search('Reservations'):
        for instance in r['Instances']:
            service_tag = find_tag('CmsService', instance.get('Tags', []))
            if service_tag == None:
                print("[%s] %s: No service tag" % (cluster, instance['InstanceId']))
                continue
            service_names = set(service_tag.split(','))
            service_names.add('ResourceService') # Every servers should run
            print("[%s] %s: %s" % (cluster, instance['InstanceId'], service_names))
            for service_name in service_names:
                if services.get(service_name) == None:
                    services[service_name] = []
                services[service_name].append([instance['PrivateIpAddress'], service_name_to_port[service_name]])

    return services

def generate(cluster):
    print("Generating for cluster: %s" % (cluster))

    base_config_key = "cms/%s/base.json" % (cluster)
    config_key = "cms/%s/config.json" % (cluster)

    services = generate_ec2_services(cluster)
    config = json.loads(s3.get_object(Bucket=s3_bucket, Key=base_config_key)['Body'].read())

    if config.get('core_services') == None:
        config['core_services'] = {}
    for service_name, hosts in services.items():
        if config['core_services'].get(service_name) == None:
            config['core_services'][service_name] = []
        config['core_services'][service_name] += hosts

    s3.put_object(Bucket=s3_bucket, Key=config_key, ContentType='application/json', Body=json.dumps(config))


def handle(event, context):
    if event.get('cluster'):
        generate(event['cluster'])
        return

    records = event.get('Records', [])
    for record in records:
        if record.get('s3') == None:
            continue
        key_match = s3_key_regexp.match(record['s3']['object']['key'])
        if not key_match:
            continue

        cluster = key_match.group(1)
        generate(cluster)
        return

    detail = event.get('detail', {})
    if detail.get('eventType') == 'AwsApiCall':
        event_name = detail.get('eventName')
        if event_name != 'CreateTags' and event_name != 'DeleteTags':
            return
        tags = event['detail']['requestParameters']['tagSet']['items']

        target_instance_ids = []
        clusters = []
        for tag in tags:
            if tag['key'] == 'CmsCluster':
                clusters.append(tag['value'])
            if tag['key'] == 'CmsService':
                instance_ids = [rs['resourceId'] for rs in event['detail']['requestParameters']['resourcesSet']['items'] if rs['resourceId'] and rs['resourceId'].startswith('i-')]
                target_instance_ids += instance_ids

        if len(target_instance_ids) > 0:
            pager = ec2.get_paginator('describe_instances').paginate(InstanceIds=target_instance_ids)
            for r in pager.search('Reservations'):
                for instance in r['Instances']:
                    cluster = find_tag('CmsCluster', instance.get('Tags', []))
                    if cluster:
                        clusters.append(cluster)

        for cluster in clusters:
            generate(cluster)

    return
