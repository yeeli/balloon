# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "balloon/version"

Gem::Specification.new do |spec|
  spec.name        = "balloon"
  spec.version     = Balloon::VERSION
  spec.authors     = ["yeeli"]
  spec.email       = ["yeeli@outlook.com"]

  spec.homepage    = "https://github.com/yeeli/balloon"
  spec.summary     = %q{Ruby image upload libary}
  spec.description = %q{Ruby image upload libary}

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage


  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_dependency "activesupport"
  spec.add_dependency "mini_magick"
  spec.add_dependency "faraday"
  spec.add_dependency "mime-types"

  # Development dependency

  spec.add_development_dependency "rails"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "mongo_mapper"
  spec.add_development_dependency "mongoid"
  spec.add_development_dependency "bson_ext"
  spec.add_development_dependency "activerecord"
end
