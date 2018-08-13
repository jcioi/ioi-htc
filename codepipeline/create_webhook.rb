require 'aws-sdk-codepipeline'
require 'securerandom'

abort "Usage: #$0 [pipeline-name ...]" unless ARGV[0]

cp = Aws::CodePipeline::Client.new(region: 'ap-northeast-1')

webhooks = {}
cp.list_webhooks().each do |page|
  page.webhooks.each do |webhook|
    webhooks[webhook.definition.target_pipeline] = webhook
  end
end

ARGV.each do |name|
  name = File.basename(name.sub(/\.rb\z/, ''))
  puts "==> #{name}"
  if webhooks[name]
    puts " * Skipping"
    next
  end
  cp.put_webhook(
    webhook: {
      name: "#{name}-GitHub",
      target_pipeline: name,
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
    webhook_name: "#{name}-GitHub",
  )
end
