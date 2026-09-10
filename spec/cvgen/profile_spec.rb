# frozen_string_literal: true

RSpec.describe Cvgen::Profile do
  let(:content) do
    {
      "basics" => { "name" => "Ada", "headline" => "Engineer", "quote" => "q" },
      "summary" => "Summary text",
      "quote" => "",
      "essential_skills" => [
        { "text" => "Ruby", "tags" => %w[ruby] },
        { "text" => "Python", "tags" => %w[python] }
      ],
      "additional_skills" => [
        { "text" => "Docker", "tags" => %w[docker] }
      ],
      "languages" => [],
      "experience" => [
        { "organization" => "Acme Corp", "title" => "Dev", "dates" => "", "url" => "", "highlights" => [],
          "tags" => [] },
        { "organization" => "Secret Labs", "title" => "Intern", "dates" => "", "url" => "", "highlights" => [],
          "tags" => [] },
        { "organization" => "Other Co", "title" => "Lead", "dates" => "", "url" => "", "highlights" => [],
          "tags" => [] }
      ],
      "education" => [],
      "projects" => [],
      "interests" => []
    }
  end

  it "loads a shipped profile from the gem root" do
    profile = described_class.load(Cvgen::ROOT, "default")
    expect(profile.name).to eq("default")
    expect(profile.layout).not_to be_empty
    expect(profile.theme_name).not_to be_empty
  end

  it "raises when profile is missing" do
    expect { described_class.load(Cvgen::ROOT, "no-such-profile") }
      .to raise_error(Cvgen::SchemaError, /not found/)
  end

  it "does not invent display text" do
    profile = described_class.new("name" => "x", "layout" => "two-column", "theme" => "default")
    result = profile.apply(content)

    expect(result["basics"]["name"]).to eq("Ada")
    expect(result["basics"]["headline"]).to eq("Engineer")
    expect(result["summary"]).to eq("Summary text")
  end

  it "fills quote from basics when section is empty" do
    profile = described_class.new("name" => "x")
    expect(profile.apply(content)["quote"]).to eq("q")
  end

  it "filters skills by include list" do
    profile = described_class.new(
      "name" => "x",
      "include" => { "skills" => %w[ruby] }
    )
    result = profile.apply(content)

    expect(result["essential_skills"].map { |s| s["text"] }).to eq(["Ruby"])
    expect(result["additional_skills"]).to be_empty
  end

  it "excludes experience by organization substring" do
    profile = described_class.new("name" => "x", "exclude" => ["secret"])
    orgs = profile.apply(content)["experience"].map { |e| e["organization"] }
    expect(orgs).not_to include("Secret Labs")
    expect(orgs).to include("Acme Corp")
  end

  it "limits experience items" do
    profile = described_class.new("name" => "x", "max_experience_items" => 1)
    expect(profile.apply(content)["experience"].size).to eq(1)
  end
end
