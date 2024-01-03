source "https://rubygems.org"

gem 'activesupport'
gem 'archivesspace-client'
gem 'net-sftp'
gem 'net-ssh'
gem 'nokogiri'
gem 'rake'
gem 'whenever', require: false

group :development do
  gem "capistrano", "~> 3.16.0"
  gem "capistrano-bundler"
end

group :test do
  gem "rspec_junit_formatter"
end

group :development, :test do
  gem "byebug"
  gem "rspec", require: false
  gem "rubocop",  "~> 1.27.0", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "timecop"
  gem "webmock"
end
