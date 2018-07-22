# -*- mode: ruby -*-
# vi: set ft=ruby :
managed_policy "CodeBuildCachePolicy-ioi18-cms-ap-northeast-1", :path=>"/service-role/" do
  {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Action"=>["s3:GetObject", "s3:PutObject"],
        "Resource"=>["arn:aws:s3:::ioi18-codebuild-cache/*"]}]}
end
