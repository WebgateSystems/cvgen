# frozen_string_literal: true

RSpec.describe Cvgen::Parser do
  def parse(text)
    described_class.new(text).parse
  end

  it "parses front matter into basics" do
    content = parse(FixtureRoot::SAMPLE_MD)

    expect(content["basics"]["name"]).to eq("Test Person")
    expect(content["basics"]["headline"]).to eq("Developer")
    expect(content["basics"]["email"]).to eq("test@example.com")
  end

  it "parses summary prose" do
    expect(parse(FixtureRoot::SAMPLE_MD)["summary"]).to include("short summary")
  end

  it "parses skill bullets and HTML tags comments" do
    skills = parse(FixtureRoot::SAMPLE_MD)["essential_skills"]

    expect(skills.map { |s| s["text"] }).to include("Ruby", "Rails")
    expect(skills.find { |s| s["text"] == "Rails" }["tags"]).to include("ruby", "rails")
  end

  it "parses experience entries with dates and highlights" do
    experience = parse(FixtureRoot::SAMPLE_MD)["experience"]

    expect(experience.size).to eq(2)
    first = experience.first
    expect(first["organization"]).to eq("Acme Corp")
    expect(first["title"]).to eq("Engineer")
    expect(first["dates"]).to eq("2020 - 2024")
    expect(first["highlights"].first["text"]).to include("Built things")
  end

  it "parses projects with urls" do
    md = <<~MD
      ---
      name: Ada
      ---

      # Projects

      ## Side App
      ### Author
      2024 - ongoing
      https://example.com/app

      - Shipped MVP
    MD

    project = parse(md)["projects"].first
    expect(project["organization"]).to eq("Side App")
    expect(project["url"]).to eq("https://example.com/app")
    expect(project["highlights"].first["text"]).to eq("Shipped MVP")
  end

  it "maps About Me to summary" do
    md = <<~MD
      ---
      name: Ada
      ---

      # About Me

      Hello world.
    MD

    expect(parse(md)["summary"]).to eq("Hello world.")
  end

  it "raises on invalid front matter" do
    expect { parse("---\nbad\n") }
      .to raise_error(Cvgen::SchemaError, /front matter/)
  end

  it "parses the shipped junior sample" do
    path = Cvgen::ROOT.join("spec", "fixtures", "cv-junior.md")
    content = described_class.parse(path)
    expect(content["basics"]["name"]).to eq("Alex Johnson")
    expect(content["essential_skills"]).not_to be_empty
    expect(content["experience"]).not_to be_empty
    expect(content["projects"]).not_to be_empty
  end
end
