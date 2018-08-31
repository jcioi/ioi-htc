# -*- mode: ruby -*-
# vi: set ft=ruby :
role "FederatedHTCAdmin", :path=>"/" do
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
              "arn:aws:iam::341857463381:root", # sorah
              "arn:aws:iam::357374668541:root", # wafrelka
              "arn:aws:iam::436825298211:root", # hanazuki
              "arn:aws:iam::461017142772:root", # sei1tani
              "arn:aws:iam::486414336274:root", # nana
              "arn:aws:iam::318177903959:root", # tyage
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
    "arn:aws:iam::aws:policy/AdministratorAccess",
  )
end
