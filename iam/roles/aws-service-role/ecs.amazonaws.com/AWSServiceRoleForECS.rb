# -*- mode: ruby -*-
# vi: set ft=ruby :
role "AWSServiceRoleForECS", :path=>"/aws-service-role/ecs.amazonaws.com/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"ecs.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
  )
end
