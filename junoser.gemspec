# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'junoser/version'

Gem::Specification.new do |spec|
  spec.name          = "junoser"
  spec.version       = Junoser::VERSION
  spec.authors       = ["Shintaro Kojima"]
  spec.email         = ["goodies@codeout.net"]

  spec.summary       = %q{PEG parser for JUNOS configuration.}
  spec.description   = %q{PEG parser to vefiry and translate into different formats for JUNOS configuration.}
  spec.homepage      = "https://github.com/codeout/junoser"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "parslet"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activesupport", "~> 4"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "test-unit"
end
