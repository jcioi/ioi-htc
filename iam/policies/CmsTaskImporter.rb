managed_policy "CmsTaskImporter", path => path do
  {
    "Version"=>"2012-10-17",
    "Statement"=>[
      {
        "Effect" => "Allow",
        "Action" => %w(
          codepipeline:PollForJobs
          codepipeline:AcknowledgeJob
          codepipeline:GetJobDetails
          codepipeline:PutJobSuccessResult
          codepipeline:PutJobFailureResult
        ),
        "Resource" => %w(
          *
        ),
      }
    ]
  }
end
