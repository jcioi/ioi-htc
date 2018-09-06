bucket "ioi18-cms-files-prd" do
  {
    "Version" => "2012-10-17",
    "Statement" => [
      {
        "Effect" => "Allow",
        "Principal" => {"AWS"=>"*"},
        "Action" => %w(s3:GetObject s3:ListBucket),
        "Resource" => %w(
          arn:aws:s3:::ioi18-cms-files-prd
          arn:aws:s3:::ioi18-cms-files-prd/*
        ),
        "Condition" => {
          "StringEquals" => {
            "aws:SourceVpc" => %w(vpc-03eed691a6a5a03b2),
          },
        },
      },
    ]
  }
end
