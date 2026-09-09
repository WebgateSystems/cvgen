# frozen_string_literal: true

require "thor"

module Cvgen
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :root, type: :string, default: nil, desc: "Project root (default: repo root)"

    desc "import PATH", "Copy a Markdown CV into content/ (validates basics)"
    method_option :name, type: :string, default: nil, desc: "Destination basename without .md"
    method_option :build, type: :boolean, default: false, aliases: "-b",
                          desc: "Run interactive build after import"
    def import(path)
      result = Importer.new(root: project_root).import!(path, name: options[:name])
      if result[:skipped_copy]
        say "Already in content/ → #{result[:path]} (validated)"
      else
        say "Imported → #{result[:path]}"
        say "Backup   → #{result[:backup]}" if result[:backup]
      end

      if options[:build]
        build_with(
          content: result[:name],
          interactive: true
        )
      end
    rescue SchemaError => e
      raise Thor::Error, e.message
    end

    desc "build", "Build CV PDF (prompts for template when run without flags)"
    method_option :profile, aliases: "-p", type: :string, default: nil, desc: "Profile name"
    method_option :theme, aliases: "-t", type: :string, default: nil, desc: "Theme override"
    method_option :layout, aliases: "-l", type: :string, default: nil, desc: "Layout / template"
    method_option :content, aliases: "-c", type: :string, default: nil, desc: "Content basename in content/"
    method_option :fit, type: :boolean, default: false, desc: "Auto-shrink theme.scale to fit max_pages"
    method_option :scale, type: :numeric, default: nil, desc: "Force theme scale (e.g. 0.9)"
    method_option :interactive, aliases: "-i", type: :boolean, default: false,
                                desc: "Force interactive template selection"
    method_option :yes, aliases: "-y", type: :boolean, default: false, desc: "No prompts; use defaults"
    def build
      build_with(
        content: options[:content],
        profile: options[:profile],
        theme: options[:theme],
        layout: options[:layout],
        interactive: options[:interactive]
      )
    end

    desc "validate", "Validate content, profile, and theme without compiling PDF"
    method_option :profile, aliases: "-p", type: :string, default: nil
    method_option :theme, aliases: "-t", type: :string, default: nil
    method_option :content, aliases: "-c", type: :string, default: nil
    def validate
      root = project_root
      content_name = options[:content] || default_content(root)
      profile_name = options[:profile] || default_profile(root)
      profile = Profile.load(root, profile_name)
      theme_name = options[:theme] || profile.theme_name
      theme = Theme.load(root, theme_name)
      path = root.join("content", "#{content_name}.md")
      content = Parser.parse(path)
      Schema.validate_content!(content)
      profile.apply(content)
      say "OK content=#{content_name}.md profile=#{profile.name} theme=#{theme.name} layout=#{profile.layout}"
    rescue SchemaError => e
      raise Thor::Error, e.message
    end

    desc "list-profiles", "List available profiles"
    def list_profiles
      Catalog.profiles(project_root).each { |name| say name }
    end

    desc "list-themes", "List available themes"
    def list_themes
      Catalog.themes(project_root).each { |name| say name }
    end

    desc "list-layouts", "List available Typst templates"
    def list_layouts
      Catalog.layouts(project_root).each { |name| say name }
    end

    desc "list-content", "List Markdown files in content/"
    def list_content
      Catalog.content_files(project_root).each { |name| say "#{name}.md" }
    end

    desc "version", "Show cvgen version"
    def version
      say "cvgen #{Cvgen::VERSION}"
    end

    default_task :build

    no_commands do
      def project_root
        Pathname(options[:root] || Cvgen::ROOT)
      end

      def build_with(content: nil, profile: nil, theme: nil, layout: nil, interactive: false)
        root = project_root
        wants_prompt = interactive || (
          !options[:yes] &&
            content.nil? && profile.nil? && theme.nil? && layout.nil? &&
            $stdin.tty?
        )

        content_name = content || (
          wants_prompt ? pick("Content (MD)", Catalog.content_files(root), default_content(root)) : default_content(root)
        )
        profile_name = profile || (
          wants_prompt ? pick("Profile", Catalog.profiles(root), default_profile(root)) : default_profile(root)
        )
        profile_obj = Profile.load(root, profile_name)

        layout_name = layout || (
          wants_prompt ? pick("Template / layout", Catalog.layouts(root), profile_obj.layout) : profile_obj.layout
        )
        theme_name = theme || (
          wants_prompt ? pick("Theme", Catalog.themes(root), profile_obj.theme_name) : profile_obj.theme_name
        )

        result = Builder.new(
          root: root,
          profile_name: profile_name,
          theme_name: theme_name,
          layout: layout_name,
          content_name: content_name,
          fit: options[:fit],
          scale: options[:scale]
        ).build!

        say "Built #{result[:pdf]}"
        say "  content=#{result[:content]} profile=#{result[:profile]} layout=#{result[:layout]} theme=#{result[:theme]}"
        say "  scale=#{result[:scale]} pages≈#{result[:pages]}"
        say "  json=#{result[:json]}"
      rescue SchemaError => e
        raise Thor::Error, e.message
      end

      def default_content(root)
        files = Catalog.content_files(root)
        raise Thor::Error, "no markdown files in content/" if files.empty?

        files.include?("cv") ? "cv" : files.first
      end

      def default_profile(root)
        profiles = Catalog.profiles(root)
        raise Thor::Error, "no profiles found" if profiles.empty?

        profiles.include?("default") ? "default" : profiles.first
      end

      def pick(label, items, preferred)
        raise Thor::Error, "no #{label.downcase} found" if items.empty?
        return items.first if items.size == 1

        say "#{label}:"
        items.each_with_index do |item, idx|
          marker = item == preferred ? "  [default]" : ""
          say format("  %2d) %s%s", idx + 1, item, marker)
        end
        answer = ask("Choose number (Enter = default):").to_s.strip
        if answer.empty?
          return preferred if preferred && items.include?(preferred)

          return items.first
        end

        index = Integer(answer)
        raise ArgumentError unless index.between?(1, items.size)

        items[index - 1]
      rescue ArgumentError
        raise Thor::Error, "invalid choice for #{label}"
      end
    end
  end
end
