require 'aws-sdk-codepipeline'
require 'json'

abort "Usage: #$0 [pipeline-name]" unless ARGV[0]
cp = Aws::CodePipeline::Client.new(region: 'ap-northeast-1')
File.write "pipelines/#{ARGV[0]}.rb", JSON.pretty_generate(cp.get_pipeline(name: ARGV[0]).pipeline.to_h).gsub(/"(.+?)": /,'\1: ')
