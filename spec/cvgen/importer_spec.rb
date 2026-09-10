# frozen_string_literal: true

RSpec.describe Cvgen::Importer do
  let(:tmpdir) { Dir.mktmpdir }
  let(:root) { FixtureRoot.create(tmpdir) }
  let(:importer) { described_class.new(root: root) }

  after { FileUtils.remove_entry(tmpdir) }

  it "copies a markdown file into content/" do
    source = root.join("incoming.md")
    source.write(FixtureRoot::SAMPLE_MD)

    result = importer.import!(source, name: "imported")

    expect(result[:skipped_copy]).to be(false)
    expect(result[:name]).to eq("imported")
    expect(result[:path]).to eq(root.join("content", "imported.md"))
    expect(result[:path].read).to include("Test Person")
  end

  it "backs up an existing destination" do
    source = root.join("incoming.md")
    source.write(FixtureRoot::SAMPLE_MD)
    root.join("content", "cv.md").write(FixtureRoot::SAMPLE_MD.sub("Test Person", "Old Name"))

    result = importer.import!(source, name: "cv")

    expect(result[:backup]).to be_a(Pathname)
    expect(result[:backup]).to exist
    expect(result[:backup].read).to include("Old Name")
  end

  it "skips copy when source is already the destination" do
    dest = root.join("content", "cv.md")
    result = importer.import!(dest)

    expect(result[:skipped_copy]).to be(true)
    expect(result[:backup]).to be_nil
  end

  it "rejects non-markdown files" do
    path = root.join("note.txt")
    path.write("hi")
    expect { importer.import!(path) }.to raise_error(Cvgen::SchemaError, /\.md/)
  end

  it "rejects invalid content after copy" do
    source = root.join("bad.md")
    source.write("---\nheadline: only\n---\n\n# Summary\n\nx\n")

    expect { importer.import!(source, name: "bad") }
      .to raise_error(Cvgen::SchemaError, /basics\.name/)
  end
end
