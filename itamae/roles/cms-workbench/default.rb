include_role 'base'
include_cookbook 'cms'
include_cookbook 'codedeploy-agent'

include_cookbook 'github-key'

include_cookbook 'codepipeline-cms-import-task-worker'
include_cookbook 'ioi-cms-import-statement-worker'
