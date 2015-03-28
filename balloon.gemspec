# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "balloon/version"

Gem::Specification.new do |s|
  s.name        = "balloon"
  s.version     = Balloon::VERSION
  s.authors     = ["yeeli"]
  s.email       = ["yeeli@outlook.com"]
  s.homepage    = ""
  s.summary     = "Ruby image upload libary"
  s.description = %q{Ruby image upload libary}

  s.rubyforge_project = "balloon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_dependency "activesupport"
  s.add_dependency "mini_magick"
  s.add_dependency "faraday"
  s.add_dependency "mime-types"
  
  #development
  s.add_development_dependency "rails"
  s.add_development_dependency "rspec"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "mongo_mapper"
  s.add_development_dependency "mongoid"
  s.add_development_dependency "bson_ext"
  s.add_development_dependency "activerecord"
end
