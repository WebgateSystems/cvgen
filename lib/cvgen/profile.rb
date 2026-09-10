# frozen_string_literal: true

module Cvgen
  class Profile
    attr_reader :data, :name

    def self.load(root, name)
      path = Pathname(root).join("profiles", "#{name}.yaml")
      path = Pathname(root).join("profiles", "#{name}.yml") unless path.exist?
      raise SchemaError, "profile not found: #{name} (#{path})" unless path.exist?

      data = YAML.safe_load(path.read, permitted_classes: []) || {}
      data = stringify_keys(data)
      data["name"] ||= name
      Schema.validate_profile!(data)
      new(data)
    end

    def self.stringify_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys(v) }
      when Array
        obj.map { |v| stringify_keys(v) }
      else
        obj
      end
    end

    def initialize(data)
      @data = data
      @name = data["name"].to_s
    end

    def layout
      (data["layout"] || "two-column").to_s
    end

    def theme_name
      (data["theme"] || "default").to_s
    end

    def apply(content)
      result = Marshal.load(Marshal.dump(content))
      normalize_content_fields!(result)
      # Content fields (name, headline, summary, experience, …) come only from Markdown.
      # Profile may filter/select, never invent display text.
      filter_skills!(result)
      filter_experience!(result)
      result
    end

    private

    def normalize_content_fields!(result)
      result["summary"] = result.fetch("summary", "").to_s
      quote = result["quote"].to_s
      result["quote"] = quote.empty? ? result.dig("basics", "quote").to_s : quote
      result["projects"] = Array(result["projects"])
      result["interests"] = Array(result["interests"])
    end

    def filter_skills!(result)
      include_skills = Array(data.dig("include", "skills") || data.dig("include", :skills))
      return if include_skills.empty?

      wanted = include_skills.map { |s| s.to_s.downcase }
      %w[essential_skills additional_skills].each do |key|
        result[key] = Array(result[key]).select { |item| skill_matches?(item, wanted) }
      end
    end

    def skill_matches?(item, wanted)
      text = item.is_a?(Hash) ? item["text"].to_s : item.to_s
      tags = item.is_a?(Hash) ? Array(item["tags"]) : []
      hay = "#{text} #{tags.join(' ')}".downcase
      wanted.any? { |w| hay.include?(w) }
    end

    def filter_experience!(result)
      exclude = Array(data["exclude"]).map(&:to_s)
      if exclude.any?
        result["experience"] = Array(result["experience"]).reject do |entry|
          exclude.any? { |ex| entry["organization"].to_s.downcase.include?(ex.downcase) }
        end
      end

      max_items = data["max_experience_items"]
      result["experience"] = Array(result["experience"]).first(Integer(max_items)) if max_items
    end
  end
end
