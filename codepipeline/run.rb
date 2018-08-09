require 'aws-sdk-codepipeline'

abort "Usage: #$0 [pipeline-name ...]" unless ARGV[0]

cp = Aws::CodePipeline::Client.new(region: 'ap-northeast-1')
ARGV.each do |name|
  name = File.basename(name.sub(/\.rb\z/, ''))
  p name
  cp.start_pipeline_execution(name: name)
end
