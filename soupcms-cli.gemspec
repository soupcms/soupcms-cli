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
  spec.homepage      = 'http://blog.soupcms.com/posts/setup-blog-site'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('thor', '~> 0.19')
  spec.add_runtime_dependency('mongo', '~> 1.10')
  spec.add_runtime_dependency('bson_ext', '~> 1.10')
  spec.add_runtime_dependency('cloudinary', '~> 1.0')

end
