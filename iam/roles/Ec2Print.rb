role "Ec2Print", :path=>"/" do
  instance_profiles(
    "Ec2Print",
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

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/IoiCodeDeploy",
  )
end

instance_profile "Ec2Print", :path=>"/"
