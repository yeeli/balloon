$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'balloon/version'

Gem::Specification.new do |spec|
  spec.name        = 'balloon'
  spec.version     = Balloon::VERSION
  spec.authors     = ['yeeli']
  spec.email       = ['yeeli@outlook.com']

  spec.homepage    = 'https://github.com/yeeli/balloon'
  spec.summary     = 'Ruby image upload libary'
  spec.description = 'Ruby image upload libary'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'mini_magick'

  # Development dependency

  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'bson_ext'
  spec.add_development_dependency 'mongoid'
  spec.add_development_dependency 'mongo_mapper'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec'
end
