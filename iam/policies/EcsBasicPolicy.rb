managed_policy "EcsBasicPolicy", :path => path do
  {
    "Version"=>"2012-10-17",
    "Statement"=>[
      {
        "Effect" => "Allow",
        "Action" => [
          "s3:GetObject",
        ],
        "Resource" => %w(
          arn:aws:s3:::ioi18-infra/hako/front-config/*
        )
      }
    ]
  }
end
