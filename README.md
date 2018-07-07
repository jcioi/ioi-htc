# IOI HTC primary repo

## Prerequisite

### SSH

- [`ssh_config`](./ssh_config)
- id_rsa.ioi18 (ITC Google Drive)

### AWS Access

https://scrapbox.io/ioi18/AWS

All the following tools require you to have proper `AWS_*` environment variables for the `ioi18` AWS account.

## Tools

### mitamae: Server Provisioning

``` sh
cd server/

bundle exec hocho apply servername --dry-run
bundle exec hocho apply servername

rm -v tmp/hocho-ec2-cache.* # Purge cache (default up to 3600s)
```

hocho-ec2.gem loads EC2 instance information for you. Make sure an instance to have `Name` and `Role` tag. Specific overriding can be done with manually creating `hosts/*.yml`.

### roadworker: DNS

```
cd route53/

bundle exec roadwork -a --dry-run
bundle exec roadwork -a
```

We have 2 Route53 hosted zones with same name for split DNS.

## piculet: EC2 Security Groups

```
cd sg/

bundle exec piculet -a --dry-run
bundle exec piculet -a
```

## miam: AWS IAM

```
cd iam/

bundle exec miam -a --dry-run
bundle exec miam -a
```
