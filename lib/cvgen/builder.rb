# frozen_string_literal: true

module Cvgen
  class Builder
    def initialize(root: Cvgen::ROOT, profile_name:, theme_name: nil, layout: nil,
                   content_path: nil, content_name: nil, fit: false, scale: nil)
      @root = Pathname(root)
      @profile = Profile.load(@root, profile_name)
      @theme_name = theme_name || @profile.theme_name
      @layout = layout || @profile.layout
      @content_path = resolve_content_path(content_path, content_name)
      @theme = Theme.load(@root, @theme_name)
      @fit = fit
      @scale = scale.nil? ? nil : Float(scale)
    end

    def build!
      content = Parser.parse(@content_path)
      Schema.validate_content!(content)
      selected = @profile.apply(content)
      max_pages = Integer(@profile.data["max_pages"] || 2)

      build_dir = @root.join("build")
      FileUtils.mkdir_p(build_dir)
      json_path = build_dir.join("resume.json")
      layout_path = @root.join("layouts", "#{@layout}.typ")
      raise SchemaError, "layout not found: #{layout_path}" unless layout_path.exist?

      stem = @content_path.basename(".*").to_s
      pdf_path = build_dir.join("cv-#{@profile.name}-#{stem}.pdf")

      used_scale = @scale || @theme.scale
      if @fit
        used_scale = fit_scale!(selected, json_path, layout_path, pdf_path, max_pages, used_scale)
      else
        write_resume!(selected, json_path, used_scale)
        compile_typst!(layout_path, pdf_path)
      end

      {
        json: json_path,
        pdf: pdf_path,
        profile: @profile.name,
        theme: @theme.name,
        layout: @layout,
        content: @content_path.basename.to_s,
        scale: used_scale,
        pages: PdfPages.count(pdf_path)
      }
    end

    private

    def resolve_content_path(content_path, content_name)
      return Pathname(content_path) if content_path

      if content_name
        path = @root.join("content", "#{content_name}.md")
        raise SchemaError, "content not found: #{path}" unless path.exist?

        return path
      end

      @root.join("content", "cv.md")
    end

    def write_resume!(selected, json_path, scale)
      resume = {
        "meta" => {
          "profile" => @profile.name,
          "theme" => @theme.name,
          "layout" => @layout,
          "content" => @content_path.basename.to_s,
          "generator" => "cvgen",
          "version" => Cvgen::VERSION,
          "scale" => Float(scale)
        },
        "basics" => selected["basics"],
        "summary" => selected["summary"].to_s,
        "quote" => selected["quote"].to_s,
        "essential_skills" => selected["essential_skills"],
        "additional_skills" => selected["additional_skills"],
        "languages" => selected["languages"],
        "experience" => selected["experience"],
        "education" => selected["education"],
        "projects" => selected.fetch("projects", []),
        "interests" => selected.fetch("interests", []),
        "theme" => @theme.scaled(scale)
      }
      json_path.write(JSON.pretty_generate(resume))
    end

    def fit_scale!(selected, json_path, layout_path, pdf_path, max_pages, start_scale)
      scale = Float(start_scale)
      min_scale = 0.7
      step = 0.05

      loop do
        write_resume!(selected, json_path, scale)
        compile_typst!(layout_path, pdf_path)
        pages = PdfPages.count(pdf_path)
        return scale if pages <= max_pages || scale <= min_scale + 0.001

        scale = (scale - step).round(2)
        scale = min_scale if scale < min_scale
      end
    end

    def compile_typst!(layout_path, pdf_path)
      cmd = ["typst", "compile", "--root", @root.to_s, layout_path.to_s, pdf_path.to_s]
      stdout, stderr, status = Open3.capture3(*cmd, chdir: @root.to_s)
      return if status.success?

      message = [stderr, stdout].reject(&:empty?).join("\n")
      raise SchemaError, "typst compile failed:\n#{message}"
    end
  end
end
