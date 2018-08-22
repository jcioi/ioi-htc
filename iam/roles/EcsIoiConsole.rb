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

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/EcsBasicPolicy",
  )
end
