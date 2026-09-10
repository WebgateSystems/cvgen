# frozen_string_literal: true

RSpec.describe Cvgen::Builder do
  let(:tmpdir) { Dir.mktmpdir }
  let(:root) { FixtureRoot.create(tmpdir) }

  after { FileUtils.remove_entry(tmpdir) }

  def stub_typst!(builder)
    allow(builder).to receive(:compile_typst!) do |_layout, pdf_path|
      Pathname(pdf_path).binwrite("%PDF-1.4\n/Type /Page\n")
    end
  end

  it "writes resume.json and returns build metadata" do
    builder = described_class.new(
      root: root,
      profile_name: "default",
      content_name: "cv",
      scale: 0.9
    )
    stub_typst!(builder)

    result = builder.build!

    expect(result[:json]).to exist
    expect(result[:pdf]).to exist
    expect(result[:profile]).to eq("default")
    expect(result[:layout]).to eq("two-column")
    expect(result[:theme]).to eq("test")
    expect(result[:scale]).to eq(0.9)
    expect(result[:pages]).to eq(1)

    resume = JSON.parse(result[:json].read)
    expect(resume.dig("basics", "name")).to eq("Test Person")
    expect(resume.dig("meta", "generator")).to eq("cvgen")
    expect(resume.dig("meta", "version")).to eq(Cvgen::VERSION)
    expect(resume.dig("theme", "scale")).to eq(0.9)
    expect(resume["essential_skills"]).not_to be_empty
  end

  it "applies profile filters before writing JSON" do
    root.join("profiles", "filtered.yaml").write(<<~YAML)
      name: filtered
      layout: two-column
      theme: test
      include:
        skills:
          - ruby
      max_experience_items: 1
    YAML

    builder = described_class.new(root: root, profile_name: "filtered", content_name: "cv")
    stub_typst!(builder)
    resume = JSON.parse(builder.build![:json].read)

    expect(resume["essential_skills"].map { |s| s["text"] }).to eq(%w[Ruby Rails])
    expect(resume["experience"].size).to eq(1)
  end

  it "raises when layout is missing" do
    root.join("profiles", "broken.yaml").write(<<~YAML)
      name: broken
      layout: missing-layout
      theme: test
    YAML

    builder = described_class.new(root: root, profile_name: "broken", content_name: "cv")
    expect { builder.build! }.to raise_error(Cvgen::SchemaError, /layout not found/)
  end

  it "raises when content is missing" do
    expect do
      described_class.new(root: root, profile_name: "default", content_name: "nope")
    end.to raise_error(Cvgen::SchemaError, /content not found/)
  end

  context "when typst is available", :integration do
    before do
      skip "typst not installed" unless system("typst", "--version", out: File::NULL, err: File::NULL)
    end

    it "compiles a real PDF from a shipped layout" do
      Dir.mktmpdir do |dir|
        root = FixtureRoot.create(dir)
        FileUtils.cp_r(Cvgen::ROOT.join("layouts").children, root.join("layouts"))
        FileUtils.cp_r(Cvgen::ROOT.join("themes").children, root.join("themes"))
        FileUtils.cp_r(Cvgen::ROOT.join("profiles").children, root.join("profiles"))
        FileUtils.cp_r(Cvgen::ROOT.join("assets").children, root.join("assets")) if Cvgen::ROOT.join("assets").exist?
        root.join("content", "cv-junior.md").write(
          Cvgen::ROOT.join("spec/fixtures/cv-junior.md").read
        )

        builder = described_class.new(
          root: root,
          profile_name: "default",
          layout: "two-column",
          theme_name: "default",
          content_name: "cv-junior",
          scale: 1.0
        )

        result = builder.build!
        expect(result[:pdf]).to exist
        expect(result[:pdf].size).to be > 1000
        expect(result[:pages]).to be >= 1
      end
    end
  end
end
