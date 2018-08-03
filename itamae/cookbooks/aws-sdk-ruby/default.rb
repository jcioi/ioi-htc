%w(
  aws-sdk-ec2
  aws-sdk-s3
  aws-sdk-codedeploy
  aws-sdk-core
).each do |_|
  gem_package _ do
  end
end
