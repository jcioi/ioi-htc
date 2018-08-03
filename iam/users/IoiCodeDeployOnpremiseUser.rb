user "IoiCodeDeployOnpremiseUser", :path=>"/" do
  policy "assume-role" do
    {
      "Version" => "2012-10-17",
      "Statement" => [
        {
          "Effect" => "Allow",
          "Action" => %w(sts:AssumeRole),
          "Resource" => %w(
            arn:aws:iam::550372229658:role/IoiCodeDeployOnpremiseRole
          )
        },
        {
          "Effect" => "Allow",
          "Action" => %w(
            codedeploy:RegisterOnPremisesInstance
            codedeploy:AddTagsToOnPremisesInstances
          ),
          "Resource" => %w(
            *
          )
        },
      ],
    }
  end
end


