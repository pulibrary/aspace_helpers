source "https://rubygems.org"

gem 'activesupport'
gem 'archivesspace-client', github: 'lyrasis/archivesspace-client', ref: 'a4351eb'
gem 'csv'
gem 'net-sftp'
gem 'net-ssh'
gem 'nokogiri'
gem 'rake'
gem 'whenever', require: false

group :development do
  gem "bcrypt_pbkdf"
  gem "capistrano", "~> 3.16.0"
  gem "capistrano-bundler"
  gem "ed25519"
  gem "stringio"
end

group :test do
  gem "rspec_junit_formatter"
  gem "simplecov"
  gem "simplecov-lcov"
end

group :development, :test do
  gem "byebug"
  gem "rspec", require: false
  gem "rubocop", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "timecop"
  gem "webmock"
end
