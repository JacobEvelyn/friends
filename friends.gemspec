# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "friends/version"
require "friends/post_install_message"

Gem::Specification.new do |spec|
  spec.name                 = "friends"
  spec.version              = Friends::VERSION
  spec.authors              = ["Jacob Evelyn"]
  spec.email                = ["jacobevelyn@gmail.com"]
  spec.summary              = "Spend time with the people you care about."
  spec.description          = "Spend time with the people you care about. "\
                             "Introvert-tested. Extrovert-approved."
  spec.homepage             = "https://github.com/JacobEvelyn/friends"
  spec.license              = "MIT"
  spec.post_install_message = Friends::POST_INSTALL_MESSAGE

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["friends"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # We need Ruby 2.1's default-less keyword arguments and default UTF-8
  # encoding.
  spec.required_ruby_version = ">= 2.1"

  spec.add_dependency "chronic", "~> 0.10"
  spec.add_dependency "gli", "~> 2.14"
  spec.add_dependency "paint", "~> 2.0"
  spec.add_dependency "semverse", ">= 2", "< 4"
  spec.add_dependency "tty-pager", "~> 0.11"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency "minitest-proveit", "~> 1.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "simplecov", "~> 0.14"
end
