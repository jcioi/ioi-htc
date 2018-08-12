# -*- mode: ruby -*-
# vi: set ft=ruby :
role "FederatedHSCUser", :path=>"/" do
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

  policy 'cwl-codebuild' do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Resource" => "*",
          "Action" => %w(
            logs:DescribeLog*
          ),
        },
        {
          "Effect"=>"Allow",
          "Resource"=>%w(
            arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/*
            arn:aws:logs:ap-northeast-1:550372229658:log-group:/aws/codebuild/*:*
          ),
          "Action"=>%w(
            logs:FilterLogEvents
            logs:GetLogEvents
            logs:TestMetricFilter
          )
        },
      ],
    }
  end

  policy 'codepipeline-run' do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Resource" => %w(
            arn:aws:codepipeline:ap-northeast-1:550372229658:ioi18-task-*
            arn:aws:codepipeline:ap-northeast-1:550372229658:ioi18-task-*/*
            arn:aws:codepipeline:ap-northeast-1:550372229658:ioi18-task-*/*/*
          ),
          "Action" => %w(
            codepipeline:StartPipelineExecution
            codepipeline:RetryStageExecution
            codepipeline:PutApprovalResult
          ),
        },
      ],
    }
  end

  attached_managed_policies(
    "arn:aws:iam::aws:policy/AWSCodeBuildReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCodePipelineApproverAccess",
    "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess",
  )
end
