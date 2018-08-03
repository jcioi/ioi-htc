managed_policy "CmsDev", path: path do
  {
    "Version" => "2012-10-17",
    "Statement" => [
      {
        "Effect" => "Allow",
        "Action" => %w(
            s3:GetObject
            s3:PutObject
            s3:DeleteObject
            s3:ListBucket
        ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-cms-files-dev
            arn:aws:s3:::ioi18-cms-files-dev/*
        ),
      },
      {
        "Effect" => "Allow",
        "Action" => %w(
            s3:GetObject
        ),
          "Resource" => %w(
            arn:aws:s3:::ioi18-infra/cms/dev/config.json
        ),
      },
    ]
  }end
