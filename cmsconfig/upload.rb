require 'json'
require 'aws-sdk-s3'
require 'itamae/secrets'

cluster = ARGV[0]
abort "Usage: #$0 CLUSTER" unless cluster

@secrets = Itamae::Secrets("#{__dir__}/../itamae/secrets")

filename = "#{__dir__}/clusters/#{cluster}.rb"

obj = binding.eval(File.read(filename), filename, 1)

s3 = Aws::S3::Client.new(region: 'ap-northeast-1')
s3.put_object(
  bucket: 'ioi18-infra',
  key: "cms/#{cluster}/base.json",
  content_type: 'application/json',
  body: obj.to_json,
)
