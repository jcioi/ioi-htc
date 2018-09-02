role "Ec2CmsPrd", :path=>"/" do
  instance_profiles(
    "Ec2CmsPrd",
  )

  assume_role_policy_document do
    {
      "Version"=>"2012-10-17",
      "Statement"=> [
        {
          "Effect"=>"Allow",
          "Principal"=>{"Service"=>"ec2.amazonaws.com"},
          "Action"=>"sts:AssumeRole",
        },
      ]
    }
  end

  include_template "Ec2InstanceDefault"

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/IoiCodeDeploy",
    "arn:aws:iam::550372229658:policy/CmsTaskImporter",
    "arn:aws:iam::550372229658:policy/CmsStatementImporterPrd",
    "arn:aws:iam::550372229658:policy/CmsPrd",
    "arn:aws:iam::550372229658:policy/CmsExportPrd",
  )
end

instance_profile "Ec2CmsPrd", :path=>"/"
