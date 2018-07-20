managed_policy "IoiCodeDeploy", path => path do
  {
    "Version"=>"2012-10-17",
    "Statement"=>[
      {
        "Effect" => "Allow",
        "Action" => [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource" => %w(
          arn:aws:s3:::codepipeline-ap-northeast-1-736133319780/*

          arn:aws:s3:::aws-codedeploy-us-east-2/*
          arn:aws:s3:::aws-codedeploy-us-east-1/*
          arn:aws:s3:::aws-codedeploy-us-west-1/*
          arn:aws:s3:::aws-codedeploy-us-west-2/*
          arn:aws:s3:::aws-codedeploy-ca-central-1/*
          arn:aws:s3:::aws-codedeploy-eu-west-1/*
          arn:aws:s3:::aws-codedeploy-eu-west-2/*
          arn:aws:s3:::aws-codedeploy-eu-west-3/*
          arn:aws:s3:::aws-codedeploy-eu-central-1/*
          arn:aws:s3:::aws-codedeploy-ap-northeast-1/*
          arn:aws:s3:::aws-codedeploy-ap-northeast-2/*
          arn:aws:s3:::aws-codedeploy-ap-southeast-1/*        
          arn:aws:s3:::aws-codedeploy-ap-southeast-2/*
          arn:aws:s3:::aws-codedeploy-ap-south-1/*
          arn:aws:s3:::aws-codedeploy-sa-east-1/*
        )
      }
    ]
  }
end
