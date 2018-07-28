# -*- mode: ruby -*-
# vi: set ft=ruby :
role "LambdaCmsConfigGenerator", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"lambda.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  policy "configgen" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(
            ec2:DescribeInstances
          ),
          "Resource" => %w(
            *
          ),
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            s3:GetObject
            s3:PutObject
          ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-infra/cms/dev/base.json
            arn:aws:s3:::ioi18-infra/cms/dev/services.json
            arn:aws:s3:::ioi18-infra/cms/dev/config.json
            arn:aws:s3:::ioi18-infra/cms/practice/base.json
            arn:aws:s3:::ioi18-infra/cms/practice/services.json
            arn:aws:s3:::ioi18-infra/cms/practice/config.json
            arn:aws:s3:::ioi18-infra/cms/prd/base.json
            arn:aws:s3:::ioi18-infra/cms/prd/services.json
            arn:aws:s3:::ioi18-infra/cms/prd/config.json
          ),
        },

      ]
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/LambdaFunctionCommon"
  )
end
