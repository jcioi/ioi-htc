require 'aws-sdk-codebuild'

abort "Usage: #$0 [project-name]" unless ARGV[0]
cb = Aws::CodeBuild::Client.new(region: 'ap-northeast-1')

project = cb.batch_get_projects(names: [ARGV[0]]).projects[0]
raise "No project found" unless project

cb.update_project(
  name: project.name,
  source: project.source.to_h.merge(buildspec: File.read("buildspecs/#{ARGV[0]}.yml")),
)
