# frozen_string_literal: true

RSpec.describe Cvgen::Catalog do
  it "lists shipped profiles, themes, and layouts" do
    expect(described_class.profiles(Cvgen::ROOT)).to include("default", "lead")
    expect(described_class.themes(Cvgen::ROOT)).to include("default")
    expect(described_class.layouts(Cvgen::ROOT)).to include("two-column", "creative-split")
  end

  it "lists content files and skips backups" do
    Dir.mktmpdir do |dir|
      root = FixtureRoot.create(dir)
      root.join("content", "cv.bak-20260101-120000.md").write("x")
      files = described_class.content_files(root)

      expect(files).to include("cv")
      expect(files.grep(/bak/)).to be_empty
    end
  end

  it "ignores underscore layout stubs" do
    Dir.mktmpdir do |dir|
      root = FixtureRoot.create(dir)
      root.join("layouts", "_partial.typ").write("// ignore")
      expect(described_class.layouts(root)).to eq(["two-column"])
    end
  end
end
