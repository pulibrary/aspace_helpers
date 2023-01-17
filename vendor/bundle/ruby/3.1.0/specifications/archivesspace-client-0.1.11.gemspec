# -*- encoding: utf-8 -*-
# stub: archivesspace-client 0.1.11 ruby lib

Gem::Specification.new do |s|
  s.name = "archivesspace-client".freeze
  s.version = "0.1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mark Cooper".freeze]
  s.date = "2021-11-23"
  s.description = "Interact with ArchivesSpace via the API.".freeze
  s.email = ["mark.c.cooper@outlook.com".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Interact with ArchivesSpace via the API.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<aruba>.freeze, [">= 0"])
    s.add_development_dependency(%q<awesome_print>.freeze, ["~> 1.8.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<capybara_discoball>.freeze, [">= 0"])
    s.add_development_dependency(%q<cucumber>.freeze, [">= 0"])
    s.add_development_dependency(%q<json_spec>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["= 3.6.0"])
    s.add_development_dependency(%q<vcr>.freeze, ["= 3.0.3"])
    s.add_development_dependency(%q<webmock>.freeze, ["= 3.0.1"])
    s.add_runtime_dependency(%q<dry-cli>.freeze, ["~> 0.7"])
    s.add_runtime_dependency(%q<httparty>.freeze, ["~> 0.14"])
    s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.10"])
  else
    s.add_dependency(%q<aruba>.freeze, [">= 0"])
    s.add_dependency(%q<awesome_print>.freeze, ["~> 1.8.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<capybara_discoball>.freeze, [">= 0"])
    s.add_dependency(%q<cucumber>.freeze, [">= 0"])
    s.add_dependency(%q<json_spec>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["= 3.6.0"])
    s.add_dependency(%q<vcr>.freeze, ["= 3.0.3"])
    s.add_dependency(%q<webmock>.freeze, ["= 3.0.1"])
    s.add_dependency(%q<dry-cli>.freeze, ["~> 0.7"])
    s.add_dependency(%q<httparty>.freeze, ["~> 0.14"])
    s.add_dependency(%q<json>.freeze, ["~> 2.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.10"])
  end
end
