source "https://rubygems.org"

gem 'archivesspace-client'
gem 'activesupport'
gem 'rake'
gem 'rubocop', require: false
gem 'nokogiri'
gem 'net-sftp'
gem 'net-ssh'

gem 'whenever', require: false

group :development do
  gem "capistrano", "~> 3.16.0"
  gem "capistrano-bundler"
end

group :test do
  gem "rspec_junit_formatter"
end

group :development, :test do
  gem "rspec"
  gem "webmock"
  gem "byebug"
end
