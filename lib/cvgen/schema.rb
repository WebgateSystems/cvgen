# frozen_string_literal: true

module Cvgen
  class SchemaError < StandardError; end

  module Schema
    REQUIRED_THEME_KEYS = %w[name fonts sizes_pt colors spacing].freeze
    REQUIRED_FONT_KEYS = %w[heading body].freeze
    REQUIRED_SIZE_KEYS = %w[name headline section body small contact].freeze
    REQUIRED_COLOR_KEYS = %w[text muted accent rule].freeze
    REQUIRED_SPACING_KEYS = %w[
      page_margin_mm column_gutter_mm left_column_ratio section_gap_pt item_gap_pt
    ].freeze
    REQUIRED_BASICS = %w[name].freeze

    module_function

    def validate_theme!(theme)
      raise SchemaError, "theme must be a Hash" unless theme.is_a?(Hash)

      missing = REQUIRED_THEME_KEYS - theme.keys.map(&:to_s)
      raise SchemaError, "theme missing keys: #{missing.join(', ')}" if missing.any?

      validate_subhash!(theme["fonts"] || theme[:fonts], REQUIRED_FONT_KEYS, "fonts")
      validate_sizes!(theme["sizes_pt"] || theme[:sizes_pt])
      validate_subhash!(theme["colors"] || theme[:colors], REQUIRED_COLOR_KEYS, "colors")
      validate_spacing!(theme["spacing"] || theme[:spacing])
      validate_scale!(theme["scale"] || theme[:scale] || 1.0)
      true
    end

    def validate_profile!(profile)
      raise SchemaError, "profile must be a Hash" unless profile.is_a?(Hash)
      raise SchemaError, "profile.name is required" if blank?(profile["name"] || profile[:name])

      true
    end

    def validate_content!(content)
      raise SchemaError, "content must be a Hash" unless content.is_a?(Hash)

      basics = content["basics"] || content[:basics]
      raise SchemaError, "content.basics is required" unless basics.is_a?(Hash)

      REQUIRED_BASICS.each do |key|
        raise SchemaError, "content.basics.#{key} is required" if blank?(basics[key] || basics[key.to_sym])
      end
      true
    end

    def validate_subhash!(hash, keys, label)
      raise SchemaError, "theme.#{label} must be a Hash" unless hash.is_a?(Hash)

      missing = keys - hash.keys.map(&:to_s)
      raise SchemaError, "theme.#{label} missing keys: #{missing.join(', ')}" if missing.any?
    end

    def validate_sizes!(sizes)
      validate_subhash!(sizes, REQUIRED_SIZE_KEYS, "sizes_pt")
      sizes.each do |key, value|
        num = Float(value)
        raise SchemaError, "theme.sizes_pt.#{key} out of range (6..36)" unless (6.0..36.0).cover?(num)
      rescue ArgumentError, TypeError
        raise SchemaError, "theme.sizes_pt.#{key} must be numeric"
      end
    end

    def validate_spacing!(spacing)
      validate_subhash!(spacing, REQUIRED_SPACING_KEYS, "spacing")
      ratio = Float(spacing["left_column_ratio"] || spacing[:left_column_ratio])
      raise SchemaError, "left_column_ratio must be between 0.15 and 0.85" unless (0.15..0.85).cover?(ratio)
    rescue ArgumentError, TypeError
      raise SchemaError, "theme.spacing.left_column_ratio must be numeric"
    end

    def validate_scale!(scale)
      num = Float(scale)
      raise SchemaError, "theme.scale must be between 0.6 and 1.4" unless (0.6..1.4).cover?(num)
    rescue ArgumentError, TypeError
      raise SchemaError, "theme.scale must be numeric"
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end
