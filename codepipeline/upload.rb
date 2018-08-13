require 'itamae/secrets'
require 'aws-sdk-codepipeline'
require 'json'
require 'securerandom'

abort "Usage: #$0 [pipeline-name]" unless ARGV[0]
@name = ARGV[0]

@secrets = Itamae::Secrets("#{__dir__}/../itamae/secrets")
cp = Aws::CodePipeline::Client.new(region: 'ap-northeast-1')

@name = @name.sub(/\.rb\z/, '')
filename = "pipelines/#{@name}.rb"
obj = binding.eval(File.read(filename), filename, 1)
obj.delete(:version)

begin
  cp.get_pipeline(name: @name)
rescue Aws::CodePipeline::Errors::PipelineNotFoundException
  cp.create_pipeline(pipeline: obj)
  cp.put_webhook(
    webhook: {
      name: "#{@name}-GitHub",
      target_pipeline: @name,
      target_action: "Source",
      filters: [
        {
          json_path: "$.ref",
          match_equals: "refs/heads/{Branch}",
        },
      ],
      authentication: "GITHUB_HMAC",
      authentication_configuration: { # required
        secret_token: SecureRandom.hex(32),
      },
    },
  )
  cp.register_webhook_with_third_party(
    webhook_name: "#{@name}-GitHub",
  )
else
  cp.update_pipeline(pipeline: obj)
end
