task = @name.gsub(/^ioi18-task-/, 'ioi-2018-')
{
  name: @name,
  role_arn: "arn:aws:iam::550372229658:role/CodePipelineServiceRole",
  artifact_store: {
    type: "S3",
    location: "codepipeline-ap-northeast-1-736133319780",
  },
  stages: [
    {
      name: "Source",
      actions: [
        {
          name: "Source",
          action_type_id: {
            category: "Source",
            owner: "ThirdParty",
            provider: "GitHub",
            version: "1"
          },
          run_order: 1,
          configuration: {
            Branch: "master",
            OAuthToken: @secrets.fetch(:github_access_token),
            Owner: "jcioi",
            PollForSourceChanges: "false",
            Repo: task,
          },
          output_artifacts: [ { name: "TaskSource" } ],
          input_artifacts: [ ],
        }
      ]
    },
    {
      name: "Build",
      actions: [
        {
          name: "CodeBuild",
          action_type_id: {
            category: "Build",
            owner: "AWS",
            provider: "CodeBuild",
            version: "1"
          },
          run_order: 1,
          configuration: {
            ProjectName: "ioi18-cmstasks"
          },
          output_artifacts: [ { name: "BuiltTask" } ],
          input_artifacts: [ { name: "TaskSource" } ],
        }
      ]
    },
    {
      name: "DeployToDev",
      actions: [
        {
          name: "cmsImportTask-dev",
          action_type_id: {
            category: "Deploy",
            owner: "Custom",
            provider: "CmsImportTask",
            version: "5b6b53fc",
          },
          run_order: 1,
          configuration: {
            cluster: "dev",
          },
          output_artifacts: [],
          input_artifacts: [{name: "BuiltTask"}],
        }
      ]
    }
  ],
}

