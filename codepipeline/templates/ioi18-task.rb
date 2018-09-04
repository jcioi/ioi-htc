APPROVED_TASKS = [
  "ioi-2018-combo",
  "ioi-2018-rectangular_permutation",
  "ioi-2018-werewolf",
  "ioi-2018-blinkenlights",
  "ioi-2018-shortest_path_query",
  "ioi-2018-meetings",
]

if @name == "ioi18-task-test-batch"
  task = "test-batch"
  practice = true
else
  task = @name.gsub(/^ioi18-task-/, 'ioi-2018-')
  practice = @name.include?('practice-')
  approved = APPROVED_TASKS.include?(task)
end
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
      ],
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
    },
    (practice || approved) ? {
      name: "PromotionApproval",
      actions: [
        {
          name: "PromotionApproval",
          action_type_id: {
            category: "Approval",
            owner: "AWS",
            version: "1",
            provider: "Manual",
          },
          input_artifacts: [],
          output_artifacts: [],
        },
      ]
    } : nil,
    (practice || approved) ? {
      name: "DeployToPrd",
      actions: [
        {
          name: "cmsImportTask-prd",
          action_type_id: {
            category: "Deploy",
            owner: "Custom",
            provider: "CmsImportTask",
            version: "5b6b53fc",
          },
          run_order: 1,
          configuration: {
            cluster: "prd",
          },
          output_artifacts: [],
          input_artifacts: [{name: "BuiltTask"}],
        }
      ]
    } : nil,
  ].compact,
}
