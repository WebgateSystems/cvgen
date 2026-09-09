# frozen_string_literal: true

module Cvgen
  class Importer
    def initialize(root:)
      @root = Pathname(root)
    end

    def import!(source_path, name: nil)
      source = Pathname(source_path).expand_path
      raise SchemaError, "file not found: #{source}" unless source.file?
      raise SchemaError, "expected a .md file: #{source}" unless source.extname.downcase == ".md"

      content_dir = @root.join("content")
      FileUtils.mkdir_p(content_dir)

      basename = sanitize_name(name.to_s.strip)
      basename = sanitize_name(source.basename(".*").to_s) if basename.empty?
      basename = "cv" if basename.empty?

      destination = content_dir.join("#{basename}.md").expand_path
      backup = nil

      if same_file?(source, destination)
        content = Parser.parse(destination)
        Schema.validate_content!(content)
        return { path: destination, name: basename, backup: nil, skipped_copy: true }
      end

      if destination.exist?
        backup = content_dir.join("#{basename}.bak-#{Time.now.strftime('%Y%m%d-%H%M%S')}.md")
        FileUtils.cp(destination, backup)
      end

      FileUtils.cp(source, destination)
      content = Parser.parse(destination)
      Schema.validate_content!(content)

      { path: destination, name: basename, backup: backup, skipped_copy: false }
    end

    private

    def same_file?(source, destination)
      return false unless destination.exist?

      source.realpath == destination.realpath
    rescue Errno::ENOENT
      false
    end

    def sanitize_name(value)
      value.to_s.gsub(/[^\w\-]+/, "-").gsub(/\A-+|-+\z/, "")
    end
  end
end
