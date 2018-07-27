# -*- mode: ruby -*-
# vi: set ft=ruby :
role "ecsTaskExecutionRole", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2008-10-17",
     "Statement"=>
      [{"Sid"=>"",
        "Effect"=>"Allow",
        "Principal"=>{"Service"=>"ecs-tasks.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  )
end
