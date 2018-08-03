# -*- mode: ruby -*-
# vi: set ft=ruby :
role "IoiCodeDeployOnpremiseRole", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 43200

  assume_role_policy_document do
    {
      "Version"=>"2012-10-17",
      "Statement"=>[
        {
          "Effect"=>"Allow",
          "Principal"=>{
            "AWS"=>[
              "arn:aws:iam::550372229658:root", # ioi18
            ]
          },
          "Action"=>"sts:AssumeRole",
          "Condition"=>{},
        },
      ],
    }
  end

  # no policy

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/IoiCodeDeploy",
  )
end
