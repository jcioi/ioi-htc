managed_policy "CmsStatementImporterDev", path => path do
  {
    "Version"=>"2012-10-17",
    "Statement"=>[
      {
        "Effect" => "Allow",
        "Action" => [
          'sqs:GetQueueUrl',
          'sqs:ReceiveMessage',
          'sqs:DeleteMessage',
        ],
        "Resource" => [
          'arn:aws:sqs:*:550372229658:cms-statement-dev',
       ],
      },
      {
        "Effect" => "Allow",
        "Action" => [
          's3:GetObject',
        ],
        "Resource" => [
          'arn:aws:s3:::ioi18-translation-files-dev/*',
        ],
      },
    ]
  }
end
