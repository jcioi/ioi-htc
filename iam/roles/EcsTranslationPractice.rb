# -*- mode: ruby -*-
# vi: set ft=ruby :
role "EcsTranslationPractice", :path=>"/" do
  max_session_duration 43200

  assume_role_policy_document do
    {"Version"=>"2012-10-17",
     "Statement"=>
       [{"Effect"=>"Allow",
         "Principal"=>{"Service"=>"ecs-tasks.amazonaws.com"},
         "Action"=>"sts:AssumeRole"}]}
  end

  policy "translation-s3" do
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
            arn:aws:s3:::ioi18-translation-files-practice
            arn:aws:s3:::ioi18-translation-files-practice/*
          ),
        },
      ]
    }
  end

  policy "translation-sqs" do
    {
      "Version"=>"2012-10-17",
      "Statement"=>[
        {
          "Effect" => "Allow",
          "Action" => [
            'sqs:GetQueueUrl',
            'sqs:SendMessage',
          ],
          "Resource" => [
            'arn:aws:sqs:*:550372229658:cms-statement-practice',
          ],
        },
      ],
    }
  end

  attached_managed_policies(
    "arn:aws:iam::550372229658:policy/EcsBasicPolicy",
  )
end
