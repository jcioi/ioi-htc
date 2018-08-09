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
cd itamae/

bundle exec hocho apply servername --dry-run
bundle exec hocho apply servername

rm -v tmp/hocho-ec2-cache.* # Purge cache (default up to 3600s)
```

hocho-ec2.gem loads EC2 instance information for you. Make sure an instance to have `Name` and `Role` tag. Specific overriding can be done with manually creating `hosts/*.yml`.

#### secret key

```
bundle exec itamae-secrets newkey --method=aes-passphrase default
```

- https://docs.google.com/spreadsheets/d/1Gfsfvb1pcnibkanu2xwjB9crrc0xp1-xDxqRCf-_fWA/edit#gid=928059752

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

## bukelatta: S3 Bucket Polcy

```
cd s3/

bundle exec bukelatta -a --dry-ryn
bundle exec bukelatta -a
```

## cfdef: CloudFront

```
cd cloudfront/

bundle exec cfdef -a --dry-run
bundle exec cfdef -a
```

## cmsconfig: CMS config.json template

```
cd cmsconfig/

# For clusters/dev.rb
bundle exec ruby upload.rb dev 

# For variants/prd/onpremise.rb
bundle exec ruby upload.rb prd onpremise
```

## hako: ECS tasks

```
cd hako/


bundle exec hako deploy nanika.jsonnet -t codebuild
```

## terraform: Misc (ELB, ...)

```
cd terraform/

terraform init
terraform apply
```

## codebuild: AWS CodeBuild buildspec

Use this when a source couldn't provide a buildspec.yml (e.g. CMS task repo)

```
cd codebuild/

bundle exec ruby set_buildspec.rb XXX
```

## codepipeline: AWS CodePipeline pipelines, custom actions

```
cd codepipeline/

# actions/XXX.rb
bundle exec create_custom_action.rb XXX

# pipelines/XXX.rb
bundle exec export.rb XXX
bundle exec upload.rb XXX

bundle exec run.rb XXX
bundle exec run.rb pipelines/ioi18-task*.rb
```

