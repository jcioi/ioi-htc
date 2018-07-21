require 'json'
require 'aws-sdk-s3'
require 'itamae/secrets'

cluster = ARGV[0]
variant = ARGV[1]
abort "Usage: #$0 CLUSTER [VARIANT]" unless cluster

@secrets = Itamae::Secrets("#{__dir__}/../itamae/secrets")

filename = if variant
             "#{__dir__}/variants/#{cluster}/#{variant}.rb"
           else
             "#{__dir__}/clusters/#{cluster}.rb"
           end

obj = binding.eval(File.read(filename), filename, 1)

s3 = Aws::S3::Client.new(region: 'ap-northeast-1')

key = if variant
        "cms/#{cluster}/config.#{variant}.json"
      else
        "cms/#{cluster}/base.json"
      end
s3.put_object(
  bucket: 'ioi18-infra',
  key: key,
  content_type: 'application/json',
  body: obj.to_json,
)
