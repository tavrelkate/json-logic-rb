# frozen_string_literal: true

require_relative "lib/json_logic/version"

Gem::Specification.new do |s|
  s.name                  = "json-logic-rb"
  s.version                = JsonLogic::VERSION

  s.summary               = "Ruby implementation of JsonLogic — simple and extensible."
  s.description           = "Ruby implementation of JsonLogic. JsonLogic rules are JSON trees. The engine walks that tree and returns a Ruby value. Ships with a compliance runner for the official test suite."

  s.authors               = ["Tavrel Kate"]

  s.license               = "MIT"
  s.required_ruby_version = ">= 3.0"

  s.homepage              = "https://github.com/tavrelkate/json-logic-rb"
  s.metadata = {
    "homepage_uri"      => "https://github.com/tavrelkate/json-logic-rb",
    "source_code_uri"   => "https://github.com/tavrelkate/json-logic-rb",
    "documentation_uri" => "https://github.com/tavrelkate/json-logic-rb",
    "changelog_uri"     => "https://github.com/tavrelkate/json-logic-rb/blob/main/CHANGELOG.md"
  }

  s.add_dependency "activesupport"

  s.files = Dir[
    "lib/**/*",
    "script/**/*",
    "README.md",
    "LICENSE",
    "test/**/*",
    "spec/**/*"
  ].uniq

  s.require_paths = ["lib"]
end
