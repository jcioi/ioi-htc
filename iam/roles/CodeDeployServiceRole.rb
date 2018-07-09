# -*- mode: ruby -*-
# vi: set ft=ruby :
role "CodeDeployServiceRole", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  assume_role_policy_document do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Sid" => "",
          "Effect" => "Allow",
          "Principal" => {
            "Service" => [
              "codedeploy.amazonaws.com"
            ]
          },
          "Action" => "sts:AssumeRole"
        }
      ]
    }
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
  )
end
