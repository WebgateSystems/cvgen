# frozen_string_literal: true

module Cvgen
  class Theme
    attr_reader :data, :name

    def self.load(root, name)
      path = Pathname(root).join("themes", "#{name}.yaml")
      path = Pathname(root).join("themes", "#{name}.yml") unless path.exist?
      raise SchemaError, "theme not found: #{name} (#{path})" unless path.exist?

      raw = YAML.safe_load(path.read, permitted_classes: []) || {}
      data = deep_stringify(raw)
      data["name"] ||= name
      data["scale"] = data.key?("scale") ? Float(data["scale"]) : 1.0
      Schema.validate_theme!(data)
      new(normalize(data))
    end

    def self.normalize(data)
      sizes = data["sizes_pt"].transform_values { |v| Float(v) }
      spacing = data["spacing"].dup
      %w[page_margin_mm column_gutter_mm left_column_ratio section_gap_pt item_gap_pt].each do |key|
        spacing[key] = Float(spacing[key])
      end
      spacing["sidebar_width_mm"] = Float(spacing["sidebar_width_mm"] || 62)
      spacing["banner_width_mm"] = Float(spacing["banner_width_mm"] || 85)
      spacing["banner_height_mm"] = Float(spacing["banner_height_mm"] || 50)
      colors = data["colors"].dup
      colors["pill_bg"] ||= "#e8f1fb"
      colors["pill_text"] ||= colors["accent"]
      colors["sidebar_bg"] ||= "#e6e6e6"

      data.merge(
        "sizes_pt" => sizes,
        "spacing" => spacing,
        "colors" => colors,
        "scale" => Float(data["scale"] || 1.0)
      )
    end

    def self.deep_stringify(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = deep_stringify(v) }
      when Array
        obj.map { |v| deep_stringify(v) }
      else
        obj
      end
    end

    def initialize(data)
      @data = data
      @name = data["name"].to_s
    end

    def scale
      Float(data["scale"] || 1.0)
    end

    # Returns a copy with sizes/spacing multiplied by scale factor (for Typst).
    def scaled(factor = nil)
      factor = Float(factor.nil? ? scale : factor)
      Schema.validate_scale!(factor)
      copy = Marshal.load(Marshal.dump(data))
      copy["scale"] = factor
      copy["sizes_pt"] = copy["sizes_pt"].transform_values { |v| (Float(v) * factor).round(2) }
      %w[section_gap_pt item_gap_pt].each do |key|
        copy["spacing"][key] = (Float(copy["spacing"][key]) * factor).round(2)
      end
      copy
    end

    def to_h
      data
    end
  end
end
