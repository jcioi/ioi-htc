role "Ec2CmsPractice", :path=>"/" do
  instance_profiles(
    "Ec2CmsPractice",
  )

  assume_role_policy_document do
    {
      "Version"=>"2012-10-17",
      "Statement"=> [
        {
          "Effect"=>"Allow",
          "Principal"=>{"Service"=>"ec2.amazonaws.com"},
          "Action"=>"sts:AssumeRole",
        },
      ]
    }
  end

  include_template "Ec2InstanceDefault"

  policy "cms-s3" do
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
            arn:aws:s3:::ioi18-cms-files-practice
            arn:aws:s3:::ioi18-cms-files-practice/*
          ),
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            s3:GetObject
          ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-infra/cms/practice/config.json
          ),
        },
      ]
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/IoiCodeDeploy",
    "arn:aws:iam::550372229658:policy/CmsTaskImporter",
  )
end

instance_profile "Ec2CmsPractice", :path=>"/"
