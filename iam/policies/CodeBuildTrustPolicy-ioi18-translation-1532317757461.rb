# -*- mode: ruby -*-
# vi: set ft=ruby :
managed_policy "CodeBuildTrustPolicy-ioi18-translation-1532317757461", :path=>"/service-role/" do
  {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Action"=>
         ["ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Effect"=>"Allow",
        "Action"=>["ssm:GetParameters"],
        "Resource"=>
         "arn:aws:ssm:ap-northeast-1:550372229658:parameter/CodeBuild/*"},
       {"Effect"=>"Allow",
        "Resource"=>
         ["arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/ioi18-translation",
          "arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/ioi18-translation:*"],
        "Action"=>
         ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]},
       {"Effect"=>"Allow",
        "Resource"=>["arn:aws:s3:::codepipeline-ap-northeast-1-*"],
        "Action"=>["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]}]}
end
