import datetime
import boto3
import botocore
import os
import re

def find_tag(key, tags):
    return next((tag['Value'] for tag in tags if tag['Key'] == key), None)

def ipv4_ptr_fqdn(address):
    return '%s.in-addr.arpa.' % ('.'.join(reversed(address.split('.'))))

def ipv4_amazon_name(address):
    return 'ip-%s' % (address.replace('.','-'))

dns_label_regexp = re.compile('\A(?!-)[a-zA-Z0-9-]{1,63}(?<!-)\Z')
def is_valid_dns_label(name):
    return dns_label_regexp.match(name)

class AwsAdapter():
    def __init__(self, region, vpc_dns_name_tag='Name'):
        self.ec2 = boto3.client('ec2', region)
        self.r53 = boto3.client('route53', 'us-east-1')
        self.vpc_dns_name_tag = vpc_dns_name_tag
        self.vpcs_cache = {}
        self.cache_duration = 600

    def prefetch_vpc_names(self,vpc_ids):
        now = datetime.datetime.now().replace(tzinfo=None)
        vpc_ids_to_fetch = [x for x in vpc_ids if self.vpcs_cache.get(x) == None or (now - self.vpcs_cache[x]['ts']).total_seconds() > self.cache_duration]
        if len(vpc_ids_to_fetch) == 0:
            return
        print("VPC FETCH: %s" % (vpc_ids_to_fetch))

        vpcs = self.ec2.describe_vpcs(VpcIds=vpc_ids_to_fetch)['Vpcs']
        for vpc in vpcs:
            name = find_tag(self.vpc_dns_name_tag, vpc.get('Tags', []))
            if name:
                if not is_valid_dns_label(name):
                    print("! Invalid VPC name: %s" % (name))
                    return
                self.vpcs_cache[vpc['VpcId']] = {'ts': now, 'name': name}

    def fetch_vpc_name(self, vpc_id):
        self.prefetch_vpc_names([vpc_id])

        cache_entry = self.vpcs_cache[vpc_id]
        if cache_entry:
            return cache_entry['name']
        else:
            return None

    def ec2_instances_by_name(self, name):
        print("ec2:DescribeInstances (name): %s" % (name))
        pager = self.ec2.get_paginator('describe_instances').paginate(Filters=[{'Name': 'tag:Name','Values': [name]}])
        return [i for r in pager.search('Reservations') for i in r['Instances']]

    def ec2_instances_by_ids(self, ids):
        print("ec2:DescribeInstances (IDs): %s" % (ids))
        pager = self.ec2.get_paginator('describe_instances').paginate(InstanceIds=list(ids))
        return [i for r in pager.search('Reservations') for i in r['Instances']]

    def r53_get_rrset(self, zone, name, rtype):
        res = self.r53.list_resource_record_sets(
            HostedZoneId=zone,
            StartRecordName=name,
            StartRecordType=rtype,
            MaxItems='1',
        )
        if len(res['ResourceRecordSets']) == 0:
            return None

        rrset = res['ResourceRecordSets'][0]
        if rrset['Name'] != name:
            return None

        return rrset


    def r53_change_rrsets(self, zone, changes, ignore_invalid_change_batch=False):
        print("R53 change(%s):" % (zone))
        for change in changes:
            rrset = change['ResourceRecordSet']
            print("R53 change(%s)   [%s] %s %s %s" % (zone, change['Action'], rrset['Name'], rrset['Type'], rrset['ResourceRecords']))
        try:
            return self.r53.change_resource_record_sets(HostedZoneId=zone, ChangeBatch={'Comment': 'ec2-r53', 'Changes': changes})
        except self.r53.exceptions.InvalidChangeBatch:
            if ignore_invalid_change_batch:
                return None
            raise

class MockAdapter():
    def __init__(self):
        self.vpc_names = {}
        self.ec2_instances = []
        self.r53_received_change_sets = {}
        self.r53_error_on_rrset_deletion = False

    def prefetch_vpc_names(self, vpc_ids):
        return

    def fetch_vpc_name(self, vpc_id):
        return self.vpc_names[vpc_id]

    def ec2_instances_by_name(self, name):
        return [i for i in self.ec2_instances if find_tag('Name', i.get('Tags', [])) == name]

    def ec2_instances_by_ids(self, instance_ids):
        ids = set(instance_ids)
        return [i for i in self.ec2_instances if i['InstanceId'] in ids]

    def r53_get_rrset(self, zone, name, rtype):
        # FIXME:
        return None

    def r53_change_rrsets(self, zone, changes, ignore_invalid_change_batch=False):
        if self.r53_error_on_rrset_deletion:
            for x in changes:
                if x['Action'] == 'DELETE':
                    if ignore_invalid_change_batch:
                        return
                    raise boto3.client('route53', 'us-east-1', aws_access_key_id='dummy', aws_secret_access_key='dummy').exceptions.InvalidChangeBatch({}, '')

        if self.r53_received_change_sets.get(zone) == None:
            self.r53_received_change_sets[zone] = []
        self.r53_received_change_sets[zone].append(changes)
        return

class InstanceStateProcessor():
    def __init__(self, handler, instance_id, state):
        self.handler = handler
        self.engine = handler.engine

        self.instance_id = instance_id
        self.state = state

        self._instance = None

    def instance(self):
        if self._instance != None:
            return self._instance
        self._instance = self.engine.adapter.ec2_instances_by_ids([self.instance_id])[0]
        return self._instance

    def run(self):
        i = self.instance()
        address = i.get('PrivateIpAddress')
        vpc_id = i.get('VpcId')
        if address == None or vpc_id == None:
            return

        fqdn = "%s.%s.%s" % (ipv4_amazon_name(address), self.engine.adapter.fetch_vpc_name(vpc_id), self.engine.domain)

        rrset = self.engine.adapter.r53_get_rrset(self.engine.zone, fqdn, 'CNAME')
        if rrset == None:
            self.handler.change_rrset(self.engine.zone, {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': fqdn,
                    'Type': 'A',
                    'TTL': 60,
                    'ResourceRecords': [
                        {'Value': address},
                    ],
                },
            })

        name = find_tag('Name', i.get('Tags', []))
        if name == None:
            ptr_zone = self.engine.lookup_ptr_zone(address)
            if ptr_zone:
                self.handler.change_rrset(ptr_zone, {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': ipv4_ptr_fqdn(address),
                        'Type': 'PTR',
                        'TTL': 5,
                        'ResourceRecords': [
                            {'Value': fqdn},
                        ],
                    },
                })
        else:
            NameTagProcessor(self.handler, 'CreateTags', name, [self.instance()['InstanceId']]).run()

class NameTagProcessor():
    def __init__(self, handler, event_name, name, instance_ids):
        self.handler = handler
        self.engine = handler.engine

        self.event_name = event_name
        self.name = name
        self.target_instance_ids = set(instance_ids)

        self._named_instances = None
        self._target_instances = None
        self._upsert_instances = None
        self._deletions = None
        self._vpc_ids = None

    def named_instances(self):
        if self._named_instances != None:
            return self._named_instances
        self._named_instances = self.engine.adapter.ec2_instances_by_name(self.name)
        return self._named_instances

    def target_instances(self):
        if self._target_instances != None:
            return self._target_instances
        self._target_instances = self.engine.adapter.ec2_instances_by_ids(self.target_instance_ids)
        return self._target_instances

    def vpc_ids(self):
        if self._vpc_ids != None:
            return self._vpc_ids

        vpc_ids = set()
        processed = 0

        for i in self.named_instances():
            if i.get('VpcId') == None:
                continue
            if i['InstanceId'] in self.target_instance_ids:
                processed += 1
                vpc_ids.add(i['VpcId'])

        if processed == len(self.target_instance_ids):
            self._target_instances = self._named_instances
        else:
            for i in self.target_instances():
                if i.get('VpcId') == None:
                    continue
                vpc_ids.add(i['VpcId'])

        self._vpc_ids = vpc_ids
        return vpc_ids

    def upsert_instances(self):
        if self._upsert_instances != None:
            return self._upsert_instances
        instances = {}
        for i in self.named_instances():
            if i.get('VpcId') not in self.vpc_ids():
                continue
            if i['State']['Name'] == 'terminated':
                continue

            instance = instances.get(i['VpcId'])
            if instance == None or (instance.get('LaunchTime') and i.get('LaunchTime') and instance['LaunchTime'] > i['LaunchTime']):
                instances[i['VpcId']] = i

        self._upsert_instances = instances
        return instances

    def deletions(self):
        if self._deletions != None:
            return self._deletions

        info = []
        seen = set([i['InstanceId'] for i in self.named_instances()])
        unnamed_instance_ids = set([x for x in self.target_instance_ids if x not in seen])
        if len(unnamed_instance_ids) > 0:
            for i in self.target_instances():
                if i['InstanceId'] not in unnamed_instance_ids:
                    continue
                if i.get('VpcId') == None:
                    continue
                delete_a = self.upsert_instances().get(i['VpcId'], None) == None
                info.append({'Instance': i, 'DeleteARecord': delete_a})

        self._deletions = info
        return info



    def run(self):
        if not is_valid_dns_label(self.name):
            print("! Invalid name: %s" % (self.name))
            return

        self.engine.adapter.prefetch_vpc_names(self.vpc_ids())

        for i in self.target_instances():
            name = find_tag('Name', i.get('Tags', []))
            if self.event_name == 'CreateTags':
                if name != self.name:
                    print("! Skipping because this function is launched for Name=%s but instance %s is currently Name=%s" % (self.name, i['InstanceId'], name))
                    return
            if self.event_name == 'DeleteTags':
                if name != None:
                    print("! Skipping because this function is launched for Name deletion but instance %s is currently Name=%s" % (i['InstanceId'], name))
                    return



        for vpc_id,i in self.upsert_instances().items():
            fqdn = "%s.%s.%s" % (self.name, self.engine.adapter.fetch_vpc_name(vpc_id), self.engine.domain)
            address = i.get('PrivateIpAddress')
            if address:
                self.handler.change_rrset(self.engine.zone, {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': fqdn,
                        'Type': 'A',
                        'TTL': 60,
                        'ResourceRecords': [
                            {'Value': address},
                        ],
                    },
                })
                ptr_zone = self.engine.lookup_ptr_zone(address)
                if ptr_zone:
                    self.handler.change_rrset(ptr_zone, {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': ipv4_ptr_fqdn(address),
                            'Type': 'PTR',
                            'TTL': 60,
                            'ResourceRecords': [
                                {'Value': fqdn},
                            ],
                        },
                    })
            else:
                print("! %s (%s) no PrivateIpAddress" % (fqdn, i['InstanceId']))

        for deletion in self.deletions():
            i = deletion['Instance']
            vpc_name = self.engine.adapter.fetch_vpc_name(i['VpcId'])
            fqdn = "%s.%s.%s" % (self.name, vpc_name, self.engine.domain)
            address = i.get('PrivateIpAddress')
            if address:
                if deletion['DeleteARecord']:
                    self.handler.change_rrset(self.engine.zone, {
                        'Action': 'DELETE',
                        'ResourceRecordSet': {
                            'Name': fqdn,
                            'Type': 'A',
                            'TTL': 60,
                            'ResourceRecords': [
                                {'Value': address},
                            ],
                        },
                    })
                ptr_zone = self.engine.lookup_ptr_zone(address)
                if ptr_zone:
                    if self.engine.default_to_amazon_name:
                        fqdn = "%s.%s.%s" % (ipv4_amazon_name(address), vpc_name, self.engine.domain)
                        self.handler.change_rrset(ptr_zone, {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': ipv4_ptr_fqdn(address),
                                'Type': 'PTR',
                                'TTL': 60,
                                'ResourceRecords': [
                                    {'Value': fqdn},
                                ],
                            },
                        })
                    else:
                        self.handler.change_rrset(ptr_zone, {
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': ipv4_ptr_fqdn(address),
                                'Type': 'PTR',
                                'TTL': 60,
                                'ResourceRecords': [
                                    {'Value': fqdn},
                                ],
                            },
                        })

class Handler():
    def __init__(self, engine):
        self.engine = engine
        self.rrset_change_sets = {}
        self.rrset_deletion_sets = {}

    def run(self, event):
        if event.get('detail-type') == 'EC2 Instance State-change Notification':
            self.handle_instance_state(event['detail']['instance-id'], event['detail']['state'])
            return

        if event['detail'].get('eventType') == 'AwsApiCall':
            event_name = event['detail']['eventName']
            if not (event_name == 'CreateTags' or event_name == 'DeleteTags'):
                print("Ignoring %s" % (event_name))
                return

            instance_ids = [rs['resourceId'] for rs in event['detail']['requestParameters']['resourcesSet']['items'] if rs['resourceId'] and rs['resourceId'].startswith('i-')]
            tags = event['detail']['requestParameters']['tagSet']['items']
            print("%s for instances %s (%s)" % (event_name, instance_ids, tags))

            self.handle_tag_event(event_name, instance_ids, tags)
            return

    def change_rrset(self, zone, change):
        if change['Action'] == 'DELETE':
            sets = self.rrset_deletion_sets
        else:
            sets = self.rrset_change_sets

        if sets.get(zone) == None:
            sets[zone] = []

        sets[zone].append(change)

    def lookup_ptr_zone(self, address):
        return self.engine.lookup_ptr_zone(address)

    def handle_instance_state(self, instance_id, state):
        if state == 'terminated':
            # Cannot support removing safely
            return

        print("Instance state %s: %s" % (instance_id, state))
        self.ensure_records_for_instance(instance_id, state)

    def handle_tag_event(self, event_name, instance_ids, tags):
        for tag in tags:
            if tag['key'] == 'Alias':
                self.ensure_records_for_alias_tag(tag['value'], instance_ids)
            if tag['key'] == 'Name':
                self.ensure_records_for_name_tag(event_name, tag['value'], instance_ids)

    def ensure_records_for_instance(self, instance_id, state):
        return InstanceStateProcessor(self, instance_id, state).run()

    def ensure_records_for_name_tag(self, event_name, name, target_instance_ids):
        print("Ensuring records for Name=%s" % (name))
        return NameTagProcessor(self, event_name, name, target_instance_ids).run()

    def ensure_records_for_alias_tag(self, alias):
        # print("Ensuring records for Alias=%s" % (name))
        return

class Engine():
    def __init__(self, adapter, domain, zone, ptr_zones, default_to_amazon_name=False):
        self.adapter = adapter
        self.domain = domain
        self.zone = zone
        self.ptr_zones = ptr_zones
        self.default_to_amazon_name = default_to_amazon_name

    def handle(self, event):
        handler = Handler(self)
        handler.run(event)

        for zone_id, changes in handler.rrset_change_sets.items():
            self.adapter.r53_change_rrsets(zone_id, changes)
        for zone_id, changes in handler.rrset_deletion_sets.items():
            for change in changes:
                self.adapter.r53_change_rrsets(zone_id, [change], ignore_invalid_change_batch=True)


    def lookup_ptr_zone(self, address):
        for x in self.ptr_zones:
            if address.startswith(x['prefix']):
                return x['zone']
        return None

