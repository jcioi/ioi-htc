# -*- mode: ruby -*-
# vi: set ft=ruby :
managed_policy "s3crr_for_ioi18-cms-files-prd_to_ioi18-cms-files-prd-apne2", :path=>"/service-role/" do
  {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Action"=>["s3:Get*", "s3:ListBucket"],
        "Effect"=>"Allow",
        "Resource"=>
         ["arn:aws:s3:::ioi18-cms-files-prd",
          "arn:aws:s3:::ioi18-cms-files-prd/*"]},
       {"Action"=>
         ["s3:GetObjectVersionTagging",
          "s3:ReplicateDelete",
          "s3:ReplicateObject",
          "s3:ReplicateTags"],
        "Effect"=>"Allow",
        "Resource"=>"arn:aws:s3:::ioi18-cms-files-prd-apne2/*"}]}
end
