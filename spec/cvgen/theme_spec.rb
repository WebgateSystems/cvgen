# frozen_string_literal: true

RSpec.describe Cvgen::Theme do
  it "loads a shipped theme" do
    theme = described_class.load(Cvgen::ROOT, "default")
    expect(theme.name).to eq("default")
    expect(theme.scale).to be_a(Float)
    expect(theme.data["sizes_pt"]["name"]).to be_a(Float)
  end

  it "raises when theme is missing" do
    expect { described_class.load(Cvgen::ROOT, "no-such-theme") }
      .to raise_error(Cvgen::SchemaError, /not found/)
  end

  it "scales sizes and spacing gaps" do
    theme = described_class.load(Cvgen::ROOT, "default")
    base_name = theme.data["sizes_pt"]["name"]
    scaled = theme.scaled(0.8)

    expect(scaled["scale"]).to eq(0.8)
    expect(scaled["sizes_pt"]["name"]).to eq((base_name * 0.8).round(2))
    expect(scaled["spacing"]["section_gap_pt"]).to eq(
      (theme.data["spacing"]["section_gap_pt"] * 0.8).round(2)
    )
  end

  it "fills default color/spacing fallbacks on normalize" do
    data = FixtureRoot::MINIMAL_THEME.dup
    data["colors"] = data["colors"].dup
    data["spacing"] = data["spacing"].dup
    normalized = described_class.normalize(data)

    expect(normalized["colors"]["pill_bg"]).to eq("#e8f1fb")
    expect(normalized["spacing"]["sidebar_width_mm"]).to eq(62.0)
  end
end
