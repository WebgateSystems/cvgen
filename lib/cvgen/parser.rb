# frozen_string_literal: true

module Cvgen
  class Parser
    SECTION_MAP = {
      "summary" => :summary,
      "about me" => :summary,
      "essential skills" => :essential_skills,
      "additional skills" => :additional_skills,
      "skills" => :essential_skills,
      "key skills" => :essential_skills,
      "languages" => :languages,
      "experience" => :experience,
      "professional experience" => :experience,
      "education" => :education,
      "projects" => :projects,
      "quote" => :quote,
      "interests" => :interests
    }.freeze

    def self.parse(path)
      new(File.read(path, encoding: "UTF-8")).parse
    end

    def initialize(text)
      @text = text
    end

    def parse
      front, body = split_front_matter(@text)
      basics = normalize_basics(front)
      sections = parse_sections(body)

      {
        "basics" => basics,
        "summary" => sections[:summary].to_s,
        "quote" => (sections[:quote].to_s.empty? ? basics["quote"] : sections[:quote].to_s),
        "essential_skills" => sections[:essential_skills] || [],
        "additional_skills" => sections[:additional_skills] || [],
        "languages" => sections[:languages] || [],
        "experience" => sections[:experience] || [],
        "education" => sections[:education] || [],
        "projects" => sections[:projects] || [],
        "interests" => sections[:interests] || []
      }
    end

    private

    def split_front_matter(text)
      if text.start_with?("---")
        parts = text.split(/^---\s*$/, 3)
        raise SchemaError, "invalid YAML front matter" unless parts.length >= 3

        front = YAML.safe_load(parts[1], permitted_classes: []) || {}
        [stringify_keys(front), parts[2].to_s]
      else
        [{}, text]
      end
    end

    def normalize_basics(front)
      {
        "name" => front["name"].to_s,
        "headline" => front["headline"].to_s,
        "email" => front["email"].to_s,
        "phones" => Array(front["phones"]).map { |p| stringify_keys(p) },
        "links" => Array(front["links"]).map { |l| stringify_keys(l) },
        "location" => front["location"].to_s,
        "quote" => front["quote"].to_s,
        "slogan" => front["slogan"].to_s,
        "role_label" => front["role_label"].to_s
      }
    end

    def parse_sections(body)
      result = {}
      current = nil
      buffer = []

      body.each_line do |raw|
        line = raw.rstrip
        if (m = line.match(/\A#\s+(.+)\z/)) && !line.start_with?("##")
          flush_section!(result, current, buffer)
          current = SECTION_MAP[m[1].strip.downcase]
          buffer = []
        else
          buffer << raw
        end
      end
      flush_section!(result, current, buffer)
      result
    end

    def flush_section!(result, current, buffer)
      return if current.nil?

      text = buffer.join
      result[current] =
        case current
        when :summary, :quote
          parse_prose(text)
        when :experience, :education, :projects
          parse_entries(text)
        else
          parse_bullets(text)
        end
    end

    def parse_prose(text)
      text.each_line
          .map(&:rstrip)
          .reject { |l| l.empty? || l.match?(/<!--/) }
          .join(" ")
          .squeeze(" ")
          .strip
    end

    def parse_bullets(text)
      items = []
      text.each_line do |raw|
        line = raw.rstrip
        next if line.empty?

        if (m = line.match(/\A-\s+(.+)\z/))
          items << { "text" => m[1].strip, "tags" => [] }
        elsif (m = line.match(/<!--\s*tags:\s*(.+?)-->/)) && items.any?
          items.last["tags"] = m[1].split(",").map(&:strip).reject(&:empty?)
        end
      end
      items
    end

    def parse_entries(text)
      entries = []
      current = nil

      text.each_line do |raw|
        line = raw.rstrip
        if (m = line.match(/\A##\s+(.+)\z/))
          entries << current if current
          current = blank_entry.merge("organization" => m[1].strip)
        elsif current.nil?
          next
        elsif (m = line.match(/\A###\s+(.+)\z/))
          current["title"] = m[1].strip
        elsif line.match?(%r{\Ahttps?://})
          current["url"] = line.strip
        elsif line.match?(/\A\d{4}\s*-\s*(?:\d{4}|ongoing)\z/i)
          current["dates"] = line.strip
        elsif (m = line.match(/\A-\s+(.+)\z/))
          current["highlights"] << { "text" => m[1].strip, "tags" => [] }
        elsif (m = line.match(/<!--\s*tags:\s*(.+?)-->/))
          tags = m[1].split(",").map(&:strip).reject(&:empty?)
          if current["highlights"].any?
            current["highlights"].last["tags"] = tags
          else
            current["tags"] = tags
          end
        end
      end
      entries << current if current
      entries
    end

    def blank_entry
      {
        "organization" => "",
        "title" => "",
        "dates" => "",
        "url" => "",
        "highlights" => [],
        "tags" => []
      }
    end

    def stringify_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys(v) }
      when Array
        obj.map { |v| stringify_keys(v) }
      else
        obj
      end
    end
  end
end
