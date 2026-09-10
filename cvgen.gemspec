# frozen_string_literal: true

require_relative "lib/cvgen/version"

Gem::Specification.new do |spec|
  spec.name = "cvgen"
  spec.version = Cvgen::VERSION
  spec.authors = ["Webgate Systems"]
  spec.email = ["dev@webgatesystems.com"]

  spec.summary = "Markdown + YAML profiles/themes → Typst → PDF CV generator"
  spec.description = "Local CV-as-code pipeline with reusable Ruby library and CLI, " \
                     "intended as the core for a Rails UX on top."
  spec.homepage = "https://github.com/WebgateSystems/cvgen"
  spec.license = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/WebgateSystems/cvgen"
  spec.metadata["changelog_uri"] = "https://github.com/WebgateSystems/cvgen/releases"
  spec.metadata["bug_tracker_uri"] = "https://github.com/WebgateSystems/cvgen/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    included = %w[
      lib/**/*
      bin/cv
      layouts/**/*
      themes/**/*
      profiles/**/*
      assets/**/*
      examples/**/*
      README.md
      LICENSE
      Gemfile
      cvgen.gemspec
    ]
    Dir.glob(included).select { |f| File.file?(f) }
  end
  spec.bindir = "bin"
  spec.executables = ["cv"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"
end
