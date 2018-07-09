template "Ec2InstanceDefault" do
  # policy "AllowToAccessToEC2" do
  #   {"Version"=>"2012-10-17",
  #    "Statement"=>
  #     [
  #       {
  #         "Effect"=>"Allow",
  #         "Action"=>["ec2:Describe*"],
  #         "Resource"=>"*",
  #       },
  #       {
  #         "Effect"=>"Allow",
  #         "Action"=>["ec2:CreateTags", "ec2:DeleteTags"],
  #         "Resource"=>"*",
  #       },
  #     ]}
  # end

  # required by SSM
  policy "ssm" do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [
        {
          "Effect" => "Allow",
          "Action" => [
            "ec2:DescribeInstanceStatus"
          ],
          "Resource" => "*"
        },
        {
          "Effect" => "Allow",
          "Action" => [
            "s3:PutObject",
            "s3:GetObject",
            "s3:AbortMultipartUpload",
            "s3:ListMultipartUploadParts",
            "s3:ListBucketMultipartUploads"
          ],
          "Resource" => "arn:aws:s3:::ioi18-ssm-agent/*"
        },
        {
          "Effect" => "Allow",
          "Action" => [
            "s3:ListBucket"
          ],
          "Resource" => "arn:aws:s3:::amazon-ssm-packages-*",
        },
        {
          "Effect"=>"Allow",
          "Action"=>[
            "cloudwatch:PutMetricData"
          ],
          "Resource"=>"*",
        },
        {
          "Effect"=>"Allow",
          "Action"=>[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents"
          ],
          "Resource"=>"*",
        },
        {
          "Effect"=>"Allow",
          "Action"=>[
            "ssm:DescribeAssociation",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:GetParameters",
            "ssm:ListAssociations",
            "ssm:ListInstanceAssociations",
            "ssm:PutInventory",
            "ssm:UpdateAssociationStatus",
            "ssm:UpdateInstanceAssociationStatus",
            "ssm:UpdateInstanceInformation"
          ],
          "Resource"=>"*",
        },
        {
          "Effect"=>"Allow",
          "Action"=>[
            "ec2messages:AcknowledgeMessage",
            "ec2messages:DeleteMessage",
            "ec2messages:FailMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply"
          ],
          "Resource"=>"*",
        },

      ]}
  end
end
