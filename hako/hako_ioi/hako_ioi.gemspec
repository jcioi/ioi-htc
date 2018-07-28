Gem::Specification.new do |spec|
  spec.name          = 'hako_ioi'
  spec.version       = '0.1.0'
  spec.authors       = ['Sorah Fukumori']
  spec.email         = ['her@sorah.jp']

  spec.summary       = 'Hako extensions for IOI'
  spec.description   = 'Hako extensions for IOI'
  spec.homepage      = 'https://github.com/jcioi/ioi-htc'

  spec.metadata['allowed_push_host'] = 'https://localhost'

  spec.files         = Dir.glob("#{__dir__}/lib/**/*")
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']
  spec.add_dependency 'hako', '>= 2.0.0'
  spec.add_dependency 'aws-sdk-s3'
end
