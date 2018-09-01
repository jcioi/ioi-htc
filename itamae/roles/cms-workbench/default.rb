include_cookbook 'cms::variables'

node.reverse_merge!({
  ioi_cms_export_submissions: {
    bucket: "s3://ioi18-cms-submissions-#{node[:cms].fetch(:cluster)}",
    timezone: "Asia/Tokyo",
  }
})

include_role 'base'
include_cookbook 'cms'
include_cookbook 'codedeploy-agent'

include_cookbook 'github-key'

include_cookbook 'codepipeline-cms-import-task-worker'
include_cookbook 'ioi-cms-import-statement-worker'
include_cookbook 'ioi-cms-export-submissions'
