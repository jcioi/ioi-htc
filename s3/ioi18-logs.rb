bucket "ioi18-logs" do
  {
    "Version" => "2012-10-17",
    "Statement" => [
      {
        "Action" => [
          "s3:PutObject"
        ],
        "Effect" => "Allow",
        "Resource" => "arn:aws:s3:::ioi18-logs/elb/*",
        "Principal" => { # ELB
          "AWS" => %w(
            us-east-1	127311923021
            us-east-2	033677994240
            us-west-1	027434742980
            us-west-2	797873946194
            ca-central-1	985666609251
            eu-central-1	054676820928
            eu-west-1	156460612806
            eu-west-2	652711504416
            eu-west-3	009996457667
            ap-northeast-1	582318560864
            ap-northeast-2	600734575887
            ap-northeast-3	383597477331
            ap-southeast-1	114774131450
            ap-southeast-2	783225319266
            ap-south-1	718504428378
            sa-east-1	507241528517
          ).each_slice(2).map{ |_| "arn:aws:iam::#{_[1]}:root" },
        }
      }
    ]
  }
end
