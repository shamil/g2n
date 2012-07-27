# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "g2n/version"

Gem::Specification.new do |s|
  s.name        = "g2n"
  s.version     = G2n::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Alex Simenduev'
  s.email       = 'shamil.si@gmail.com'
  s.homepage    = "https://github.com/shamil/g2n"
  s.summary     = %q{Utilty to get hosts from Ganglia (gmetad) and create a Nagios configs}
  s.description = %q{Utilty to get hosts from Ganglia (gmetad) and create a Nagios configs, the Ganglia cluster names can be mapped to Nagios config templates}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
