# -*- mode: ruby -*-
# vi: set ft=ruby :
role "CodeBuildServiceRole", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"codebuild.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/CodeBuildCachePolicy",
    "arn:aws:iam::550372229658:policy/CodeBuildTrustPolicy",
  )
end
