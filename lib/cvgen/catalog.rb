# frozen_string_literal: true

module Cvgen
  module Catalog
    module_function

    def content_files(root)
      Dir[Pathname(root).join("content", "*.md")]
        .reject { |p| File.basename(p).include?(".bak-") }
        .sort
        .map { |p| File.basename(p, ".md") }
    end

    def profiles(root)
      Dir[Pathname(root).join("profiles", "*.{yaml,yml}")].sort.map { |p| File.basename(p, ".*") }
    end

    def themes(root)
      Dir[Pathname(root).join("themes", "*.{yaml,yml}")].sort.map { |p| File.basename(p, ".*") }
    end

    def layouts(root)
      Dir[Pathname(root).join("layouts", "*.typ")]
        .map { |p| File.basename(p, ".typ") }
        .reject { |name| name.start_with?("_") }
        .sort
    end
  end

  module PdfPages
    module_function

    # Best-effort page count for a PDF produced by Typst.
    def count(path)
      data = File.binread(path)
      pages = data.scan(%r{/Type\s*/Page(?![s\w])}).size
      return pages if pages.positive?

      if (m = data.match(%r{/Count\s+(\d+)}))
        return Integer(m[1])
      end

      1
    end
  end
end
