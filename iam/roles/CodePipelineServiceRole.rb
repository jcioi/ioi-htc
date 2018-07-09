role "CodePipelineServiceRole", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Sid"=>"",
        "Effect"=>"Allow",
        "Principal"=>{"Service"=>"codepipeline.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  policy "oneClick_AWS-CodePipeline-Service_1531173527975" do
    {"Statement"=>
      [{"Action"=>
         ["autoscaling:*",
          "cloudformation:*",
          "cloudwatch:*",
          "ec2:*",
          "ecs:*",
          "elasticbeanstalk:*",
          "elasticloadbalancing:*",
          "iam:PassRole",
          "rds:*",
          "s3:*",
          "sns:*",
          "sqs:*"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>
         ["cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate",
          "iam:PassRole"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>["codebuild:BatchGetBuilds", "codebuild:StartBuild"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>
         ["codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>
         ["codedeploy:CreateDeployment",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>["lambda:InvokeFunction", "lambda:ListFunctions"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>
         ["opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>
         ["s3:GetBucketVersioning", "s3:GetObject", "s3:GetObjectVersion"],
        "Resource"=>"*",
        "Effect"=>"Allow"},
       {"Action"=>["s3:PutObject"],
        "Resource"=>
         ["arn:aws:s3:::codepipeline*", "arn:aws:s3:::elasticbeanstalk*"],
        "Effect"=>"Allow"},
       {"Effect"=>"Allow",
        "Action"=>
         ["devicefarm:CreateUpload",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:ListDevicePools",
          "devicefarm:ListProjects",
          "devicefarm:ScheduleRun"],
        "Resource"=>"*"}],
     "Version"=>"2012-10-17"}
  end

  attached_managed_policies(
    # attached_managed_policy
  )
end
