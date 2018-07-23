# -*- mode: ruby -*-
# vi: set ft=ruby :
role "LambdaDefault", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>%w(lambda.amazonaws.com edgelambda.amazonaws.com)},
        "Action"=>"sts:AssumeRole"}]}
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/LambdaFunctionCommon"
  )
end
