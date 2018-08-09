
# -*- mode: ruby -*-
# vi: set ft=ruby :
role "EcsAwsTools", :path=>"/" do
  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
      [{"Sid"=>"",
        "Effect"=>"Allow",
        "Principal"=>{"Service"=>"ecs-tasks.amazonaws.com"},
        "Action"=>"sts:AssumeRole"}]}
  end

  policy "assumerole" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Resource" => %w(
            arn:aws:iam::550372229658:role/FederatedHSCUser
          ),
          "Action" => %w(sts:AssumeRole),
        },
      ],
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/EcsBasicPolicy",
  )
end
