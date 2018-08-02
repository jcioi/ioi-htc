# -*- mode: ruby -*-
# vi: set ft=ruby :
role "s3crr_role_for_ioi18-cms-files-prd_to_ioi18-cms-files-prd-apne2", :path=>"/service-role/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"s3.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/service-role/s3crr_for_ioi18-cms-files-prd_to_ioi18-cms-files-prd-apne2"
  )
end
