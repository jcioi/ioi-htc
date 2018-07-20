import unittest
import engine

class TestEngine(unittest.TestCase):
    def setUp(self):
        self.adapter = engine.MockAdapter()
        self.adapter.vpc_names = {
                'vpc-a': 'a',
                'vpc-b': 'b',
                }

        self.engine = engine.Engine(
                adapter=self.adapter,
                domain='test.invalid.',
                zone='ZONE',
                ptr_zones=[
                    {'prefix': '192', 'zone': 'PTRA'},
                    {'prefix': '198', 'zone': 'PTRB'},
                    ],
                default_to_amazon_name=False,
                )

    def _ec2(self, iid, vpc, ip, tags, state='running'):
        return {
                'InstanceId': iid,
                'VpcId': vpc,
                'PrivateIpAddress': ip,
                'LaunchTime': ip,
                'Tags': [{'Key': k, 'Value': v} for k,v in tags.items()],
                'State': {'Name': state},
                }


    def _ec2_tag_change(self, event_name, iids, tags):
        return  {
                    'detail': {
                        'eventType': 'AwsApiCall',
                        'eventName': event_name,
                        'requestParameters': {
                            'resourcesSet': {
                                'items': [{'resourceId': i} for i in iids],
                            },
                            'tagSet': {
                                'items': [{'key': k, 'value': v} for k,v in tags.items()],
                            },
                        },
                    },
                }

    def _ec2_state(self, iid, state):
        return  {
                    'detail-type': 'EC2 Instance State-change Notification',
                    'detail': {
                        'instance-id': iid,
                        'state': state,
                    },
                }


    def _r53_change(self, action, name, rtype, values, ttl=60):
        return {
            'Action': action,
            'ResourceRecordSet': {
                'Name': name,
                'Type': rtype,
                'TTL': ttl,
                'ResourceRecords': [{'Value': x} for x in values],
            },
        }

    def _assertRRSetChanges(self, zone, expected_changes, count=None):
        change_sets = self.adapter.r53_received_change_sets[zone]
        changes = [c for cs in change_sets for c in cs]

        self.assertCountEqual(changes, expected_changes)
        if count:
            self.assertEqual(len(change_sets), count)



    def test_ec2name_new_singlevpc(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {'Name': 'foo'}),
            self._ec2('i-b0', 'vpc-b', '198.51.100.1', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('CreateTags', ['i-a0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ])

    def test_ec2name_new_multivpc(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {'Name': 'foo'}),
            self._ec2('i-b0', 'vpc-b', '198.51.100.1', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('CreateTags', ['i-a0', 'i-b0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 3)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
            self._r53_change('UPSERT', 'foo.b.test.invalid.', 'A', ['198.51.100.1']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ])
        self._assertRRSetChanges('PTRB', [
            self._r53_change('UPSERT', '1.100.51.198.in-addr.arpa.', 'PTR', ['foo.b.test.invalid.']),
        ])


    def test_ec2name_disappear_singlevpc(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {}),
            self._ec2('i-b0', 'vpc-b', '198.51.100.1', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('DELETE', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ], count=1)
        self._assertRRSetChanges('PTRA', [
            self._r53_change('DELETE', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ], count=1)

        return

    def test_ec2name_disappear_multivpc(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {}),
            self._ec2('i-b0', 'vpc-b', '198.51.100.1', {}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a0', 'i-b0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 3)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('DELETE', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
            self._r53_change('DELETE', 'foo.b.test.invalid.', 'A', ['198.51.100.1']),
        ], count=2)
        self._assertRRSetChanges('PTRA', [
            self._r53_change('DELETE', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ], count=1)
        self._assertRRSetChanges('PTRB', [
            self._r53_change('DELETE', '1.100.51.198.in-addr.arpa.', 'PTR', ['foo.b.test.invalid.']),
        ], count=1)
        return

    def test_ec2name_disappear_amazonname(self):
        self.engine.default_to_amazon_name = True
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('DELETE', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ], count=1)
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['ip-192-0-2-1.a.test.invalid.']),
        ])
        return

    def test_ec2name_disappear_amazonname_multi(self):
        self.engine.default_to_amazon_name = True
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {'Name': 'foo'}),
            self._ec2('i-a1', 'vpc-a', '192.0.2.2', {}),
            self._ec2('i-a2', 'vpc-a', '192.0.2.3', {}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a1', 'i-a2'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ], count=1)
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
            self._r53_change('UPSERT', '2.2.0.192.in-addr.arpa.', 'PTR', ['ip-192-0-2-2.a.test.invalid.']),
            self._r53_change('UPSERT', '3.2.0.192.in-addr.arpa.', 'PTR', ['ip-192-0-2-3.a.test.invalid.']),
        ])
        return

    def test_ec2name_conflict_keep(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a1', 'vpc-a', '192.0.2.1', {'Name': 'foo'}),
            self._ec2('i-a2', 'vpc-a', '192.0.2.2', {}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a2'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
            self._r53_change('DELETE', '2.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ], count=2)
        return

    def test_ec2name_conflict_change(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a1', 'vpc-a', '192.0.2.1', {}),
            self._ec2('i-a2', 'vpc-a', '192.0.2.2', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a1'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.2']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '2.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
            self._r53_change('DELETE', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ],count=2)
        return

    def test_ec2name_conflict_rename(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a1', 'vpc-a', '192.0.2.1', {'Name': 'bar'}),
            self._ec2('i-a2', 'vpc-a', '192.0.2.2', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('CreateTags', ['i-a1'], {'Name': 'bar'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'bar.a.test.invalid.', 'A', ['192.0.2.1']),
            # self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.2']), # Cannot detect this!
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['bar.a.test.invalid.']),
            # self._r53_change('UPSERT', '2.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ])
        return

    def test_ec2name_renamed_on_delete_event_run(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a1', 'vpc-a', '192.0.2.1', {'Name': 'bar'}),
            self._ec2('i-a2', 'vpc-a', '192.0.2.2', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a1'], {'Name': 'foo'}))
        self.assertEqual(len(self.adapter.r53_received_change_sets), 0)
        return

    def test_ec2name_disappear_invalidchange(self):
        self.adapter.r53_error_on_rrset_deletion = True
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {}),
        ]

        self.engine.handle(self._ec2_tag_change('DeleteTags', ['i-a0'], {'Name': 'foo'}))

        self.assertEqual(len(self.adapter.r53_received_change_sets), 0)
        return

    def test_ec2state_upsert_unnamed(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {}),
        ]

        self.engine.handle(self._ec2_state('i-a0', 'running'))

        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'ip-192-0-2-1.a.test.invalid.', 'A', ['192.0.2.1']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['ip-192-0-2-1.a.test.invalid.'], ttl=5),
        ])
        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        return

    def test_ec2state_upsert_named(self):
        self.adapter.ec2_instances = [
            self._ec2('i-a0', 'vpc-a', '192.0.2.1', {'Name': 'foo'}),
        ]

        self.engine.handle(self._ec2_state('i-a0', 'running'))

        self._assertRRSetChanges('ZONE', [
            self._r53_change('UPSERT', 'ip-192-0-2-1.a.test.invalid.', 'A', ['192.0.2.1']),
            self._r53_change('UPSERT', 'foo.a.test.invalid.', 'A', ['192.0.2.1']),
        ])
        self._assertRRSetChanges('PTRA', [
            self._r53_change('UPSERT', '1.2.0.192.in-addr.arpa.', 'PTR', ['foo.a.test.invalid.']),
        ])
        self.assertEqual(len(self.adapter.r53_received_change_sets), 2)
        return




if __name__ == '__main__':
        unittest.main()
