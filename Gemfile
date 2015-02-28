source "https://rubygems.org"

gemspec

gem 'twitter', '~>5.14.0'
gem 'json'
gem 'ripl'
gem 'activerecord'

platforms :ruby do
  gem 'sqlite3'
  gem 'mysql2'
  gem 'activerecord-mysql2-adapter'
end

platforms :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'activerecord-jdbcmysql-adapter'
end

gem 'rspec', '~>3.0'
gem 'simplecov', :require => false, :group => :test