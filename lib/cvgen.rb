# frozen_string_literal: true

require_relative "cvgen/version"
require "json"
require "yaml"
require "fileutils"
require "pathname"
require "open3"

require_relative "cvgen/schema"
require_relative "cvgen/parser"
require_relative "cvgen/profile"
require_relative "cvgen/theme"
require_relative "cvgen/catalog"
require_relative "cvgen/importer"
require_relative "cvgen/builder"
require_relative "cvgen/cli"

module Cvgen
  # Gem / repo root (layouts, themes, profiles, assets live here).
  ROOT = Pathname.new(__dir__).join("..").expand_path
end
