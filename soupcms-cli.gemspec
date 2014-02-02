# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soupcms/cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'soupcms-cli'
  spec.version       = Soupcms::Cli::VERSION
  spec.authors       = ['Sunit Parekh']
  spec.email         = ['parekh.sunit@gmail.com']
  spec.summary       = %q{soupCMS command line interpreter}
  spec.description   = %q{soupCMS command line interpreter for generating new application and applying updates}
  spec.homepage      = 'http://www.soupcms.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

end
