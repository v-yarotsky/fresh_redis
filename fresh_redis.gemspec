# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fresh_redis/version'

Gem::Specification.new do |gem|
  gem.name          = "fresh_redis"
  gem.version       = FreshRedis::VERSION
  gem.authors       = ["Vladimir Yarotsky"]
  gem.email         = ["vladimir.yarotsky@gmail.com"]
  gem.description   = %q{An utility for Redis maintenance}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("redis", "~> 3.0")
end
