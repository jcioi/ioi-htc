managed_policy "CmsExportPrd", path: path do
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
            arn:aws:s3:::ioi18-cms-submissions-prd
            arn:aws:s3:::ioi18-cms-submissions-prd/*
        ),
      },
    ]
  }end
