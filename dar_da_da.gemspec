# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dar_da_da/version"

Gem::Specification.new do |s|
  s.name        = "dar_da_da"
  s.version     = DarDaDa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sebastian Munz"]
  s.email       = ["sebastian@yo.lk"]
  s.homepage    = "https://github.com/yolk/dar_da_da"
  s.summary     = %q{Roles easy like sunday morning.}
  s.description = %q{Roles easy like sunday morning.}

  s.rubyforge_project = "dar_da_da"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord',            '>= 3.0'

  # Actionpack is optional!
  s.add_development_dependency 'actionpack',  '>= 3.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'sqlite3'
end
