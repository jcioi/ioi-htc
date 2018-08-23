role "Ec2Prometheus", :path=>"/" do
  instance_profiles(
    "Ec2Prometheus",
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

  policy 'cloudwatch' do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(
            cloudwatch:ListMetrics
            cloudwatch:GetMetricStatistic
          ),
          "Resource" => %w(
            *
          ),
        },
      ]
    }
  end
  policy 'ec2-sd' do
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
      ]
    }
  end

end

instance_profile "Ec2Prometheus", :path=>"/"
