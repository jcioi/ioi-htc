# -*- mode: ruby -*-
# vi: set ft=ruby :
role "EcsIoiConsole", :path=>"/" do
  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Sid"=>"",
        "Effect"=>"Allow",
        "Principal"=>{"Service"=>"ecs-tasks.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  policy "route53" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(
            route53:ChangeResourceRecordSets
          ),
          "Resource" => %w(
            arn:aws:route53:::hostedzone/Z1V30A252QIS0J
          ),
        },
      ]
    }
  end

  policy "console-s3" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(
            s3:GetObject
            s3:PutObject
            s3:DeleteObject
            s3:ListBucket
          ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-console
            arn:aws:s3:::ioi18-console/*
          ),
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            s3:GetObject
          ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-infra/dhcp/leases/*
          ),
        }
      ]
    }
  end

  policy "console-sqs" do
    {
      "Version"=>"2012-10-17",
      "Statement"=>[
        {
          "Effect" => "Allow",
          "Action" => %w(
            sqs:ChangeMessageVisibility
            sqs:ChangeMessageVisibilityBatch
            sqs:DeleteMessage
            sqs:DeleteMessageBatch
            sqs:GetQueueAttributes
            sqs:GetQueueUrl
            sqs:ReceiveMessage
            sqs:SendMessage
            sqs:SendMessageBatch
            sqs:ListQueues
          ),
          "Resource" => %w(
            arn:aws:sqs:*:550372229658:ioi18-console_prd_*
            arn:aws:sqs:*:550372229658:ioi18-console_prd-dlq_*
          )
        },
      ],
    }
  end

  policy "console-ssm" do
    {
      "Version"=>"2012-10-17",
      "Statement"=>[
        {
          "Effect" => "Allow",
          "Action" => %w(
            ssm:GetCommandInvocation
          ),
          "Resource" => %w(
            *
          )
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            ssm:SendCommand
            ssm:GetDocument
          ),
          "Resource" => %w(
             arn:aws:ssm:*::document/AWS-RunShellScript
          )
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            ssm:SendCommand
          ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-console/remote-task/ssm-log/*
          )
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            ssm:SendCommand
          ),
          "Resource" => %w(
             arn:aws:ec2:*:*:instance/*
          ),
          "Condition" => {
            "StringLike" => {
               "ssm:resourceTag/CmsCluster" => [
                  "dev",
                  "prd",
               ],
            },
          },
        },
      ],
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/EcsBasicPolicy",
  )
end
