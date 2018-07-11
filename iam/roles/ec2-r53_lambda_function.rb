# -*- mode: ruby -*-
# vi: set ft=ruby :
role "ec2-r53_lambda_function", :path=>"/" do
  instance_profiles(
    # no instance_profile
  )

  max_session_duration 3600

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Effect"=>"Allow",
        "Principal"=>{"Service"=>"lambda.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  policy "ec2-r53" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(
            ec2:DescribeInstances
            ec2:DescribeVpcs
          ),
          "Resource" => %w(
            *
          ),
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            route53:ListResourceRecordSets
            route53:ChangeResourceRecordSets
          ),
          "Resource" => %w(
            arn:aws:route53:::hostedzone/Z1V30A252QIS0J
            arn:aws:route53:::hostedzone/ZIOWYU1XGG6MH
          ),
        },

      ]
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/ec2-r53_lambda_logs"
  )
end


managed_policy "ec2-r53_lambda_logs", :path=>"/" do
  {"Version"=>"2012-10-17",
     "Statement"=>[{"Action"=>["logs:*"], "Effect"=>"Allow", "Resource"=>"*"}]}
end
