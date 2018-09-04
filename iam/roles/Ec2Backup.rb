role "Ec2Backup", :path=>"/" do
  instance_profiles(
    "Ec2Backup",
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

  policy 's3' do
    {
      'Version' => '2012-10-17',
      'Statement' => [
        {
          "Effect" => "Allow",
          "Action" => %w(s3:ListBucket),
          "Resource" => %w(arn:aws:s3:::ioi18-backup),
        },
        {
          "Effect" => "Allow",
          "Action" => %w(s3:PutObject s3:GetObject s3:DeleteObject),
          "Resource" => %w(arn:aws:s3:::ioi18-backup/*),
        },
      ],
    }
  end

end

instance_profile "Ec2Backup", :path=>"/"
