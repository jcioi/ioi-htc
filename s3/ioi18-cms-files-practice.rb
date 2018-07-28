bucket "ioi18-cms-files-practice" do
  {
    "Version" => "2012-10-17",
    "Statement" => [
      {
        "Effect" => "Allow",
        "Principal" => {"AWS"=>"*"},
        "Action" => %w(s3:GetObject),
        "Resource" => %w(
          arn:aws:s3:::ioi18-cms-files-practice/*
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
