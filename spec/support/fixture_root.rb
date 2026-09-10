# frozen_string_literal: true

module FixtureRoot
  module_function

  MINIMAL_THEME = {
    "name" => "test",
    "fonts" => { "heading" => "Helvetica", "body" => "Helvetica" },
    "sizes_pt" => {
      "name" => 22, "headline" => 12, "section" => 11,
      "body" => 10, "small" => 9, "contact" => 9
    },
    "colors" => {
      "text" => "#111", "muted" => "#666", "accent" => "#06c", "rule" => "#ccc"
    },
    "spacing" => {
      "page_margin_mm" => 12,
      "column_gutter_mm" => 6,
      "left_column_ratio" => 0.35,
      "section_gap_pt" => 10,
      "item_gap_pt" => 4
    },
    "scale" => 1.0
  }.freeze

  SAMPLE_MD = <<~MD
    ---
    name: Test Person
    headline: Developer
    email: test@example.com
    ---

    # Summary

    A short summary.

    # Essential Skills

    - Ruby
    - Rails
      <!-- tags: ruby,rails -->

    # Experience

    ## Acme Corp
    ### Engineer
    2020 - 2024

    - Built things
      <!-- tags: ruby -->

    ## Secret Labs
    ### Intern
    2019 - 2020

    - Helped out
  MD

  def create(dir)
    root = Pathname(dir)
    %w[content profiles themes layouts build assets].each do |name|
      FileUtils.mkdir_p(root.join(name))
    end

    root.join("content", "cv.md").write(SAMPLE_MD)
    root.join("profiles", "default.yaml").write(<<~YAML)
      name: default
      layout: two-column
      theme: test
      max_pages: 2
    YAML
    root.join("themes", "test.yaml").write(MINIMAL_THEME.to_yaml)
    root.join("layouts", "two-column.typ").write("// test layout\n")
    root
  end
end
