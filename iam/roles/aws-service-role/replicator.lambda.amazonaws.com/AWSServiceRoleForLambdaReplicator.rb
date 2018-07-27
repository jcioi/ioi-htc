# -*- mode: ruby -*-
# vi: set ft=ruby :
role "AWSServiceRoleForLambdaReplicator", :path=>"/aws-service-role/replicator.lambda.amazonaws.com/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"replicator.lambda.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::aws:policy/aws-service-role/AWSLambdaReplicator"
  )
end
