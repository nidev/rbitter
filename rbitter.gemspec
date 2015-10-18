# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbitter/version'

Gem::Specification.new do |spec|
  spec.name          = "rbitter"
  spec.version       = Rbitter::VERSION
  spec.authors       = ["Nidev Plontra"]
  spec.email         = ["nidev.plontra@gmail.com"]
  spec.summary       = %q{Rbitter is a Twitter client specialized in archiving}
  spec.description   = %q{Rbitter archives all tweets appeared on user streaming using ActiveRecord. XMLRPC is used to serve archived tweets and useful features}
  spec.homepage      = "https://github.com/nidev/rbitter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_dependency 'twitter', '~> 5.15'
  spec.add_dependency 'json', '~> 1.7'
  spec.add_dependency 'ripl', '~> 0.7'
  spec.add_dependency 'activerecord', '~> 4.2'

  if RUBY_PLATFORM == 'java'
    spec.platform = 'java'

    spec.add_dependency 'activerecord-jdbc-adapter', '~> 1.3'
    spec.add_dependency 'jdbc-sqlite3', '~> 3.8'
    spec.add_dependency 'jdbc-mysql', '~> 5.1'
    spec.add_dependency 'activerecord-jdbcsqlite3-adapter', '~> 1.3'
    spec.add_dependency 'activerecord-jdbcmysql-adapter', '~> 1.3'
  else
    spec.platform = 'ruby'

    spec.add_dependency 'sqlite3', '~> 1.3'
    spec.add_dependency 'mysql2', '~> 0.3'
  end

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
