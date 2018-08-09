require 'itamae/secrets'
require 'aws-sdk-codepipeline'
require 'json'

abort "Usage: #$0 [action_name]" unless ARGV[0]
@name = ARGV[0]

@secrets = Itamae::Secrets("#{__dir__}/../itamae/secrets")
cp = Aws::CodePipeline::Client.new(region: 'ap-northeast-1')

filename = "actions/#{@name}.rb"
obj = binding.eval(File.read(filename), filename, 1)
cp.create_custom_action_type(obj)
