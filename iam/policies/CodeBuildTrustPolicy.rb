# -*- mode: ruby -*-
# vi: set ft=ruby :
managed_policy "CodeBuildTrustPolicy", :path=>"/" do
  {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Action"=>["ssm:GetParameters"],
        "Resource"=>
         "arn:aws:ssm:ap-northeast-1:550372229658:parameter/CodeBuild/*"},
       {"Effect"=>"Allow",
        "Resource"=>
         ["arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/*",
          "arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/*:*"],
        "Action"=>
         ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]},
       {"Effect"=>"Allow",
        "Resource"=>["arn:aws:s3:::codepipeline-ap-northeast-1-*"],
        "Action"=>["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]},
        {
          'Effect' => 'Allow',
          'Action' => [
            'ecr:GetAuthorizationToken',
            'ecr:GetDownloadUrlForLayer',
            'ecr:BatchGetImage',
            'ecr:BatchCheckLayerAvailability',
            'ecr:PutImage',
            'ecr:InitiateLayerUpload',
            'ecr:UploadLayerPart',
            'ecr:CompleteLayerUpload',
            'ecr:DescribeRepositories',
            'ecr:GetRepositoryPolicy',
            'ecr:CreateRepository',
            'ecr:PutLifecyclePolicy',
          ],
          'Resource' => '*',
        },
      ]}
end
