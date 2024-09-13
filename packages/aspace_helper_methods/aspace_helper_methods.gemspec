# frozen_string_literal: true

require_relative "lib/aspace_helper_methods/version"

Gem::Specification.new do |spec|
  spec.name = "aspace_helper_methods"
  spec.version = AspaceHelperMethods::VERSION
  spec.authors = ["Regine Heberlein", "Max Kadel", "Christina Chortaria", "Jane Sandberg"]
  spec.email = ["mkadel@princeton.edu", "cc62@princeton.edu", "heberlei@princeton.edu", "js7389@princeton.edu"]

  spec.summary = "Helper methods for ASpace Helpers"
  spec.homepage = "https://github.com/pulibrary/aspace_helpers"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pulibrary/aspace_helpers"
  spec.metadata["changelog_uri"] = "https://github.com/pulibrary/aspace_helpers/packages/aspace_helper_methods/CHANGELOG.MD"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "archivesspace-client"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
