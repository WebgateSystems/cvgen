# frozen_string_literal: true

RSpec.describe Cvgen::Schema do
  let(:valid_theme) { FixtureRoot::MINIMAL_THEME.dup.tap { |h| h["sizes_pt"] = h["sizes_pt"].dup } }

  describe ".validate_theme!" do
    it "accepts a complete theme" do
      expect(described_class.validate_theme!(valid_theme)).to be(true)
    end

    it "rejects missing top-level keys" do
      expect { described_class.validate_theme!({ "name" => "x" }) }
        .to raise_error(Cvgen::SchemaError, /missing keys/)
    end

    it "rejects out-of-range sizes" do
      valid_theme["sizes_pt"]["name"] = 99
      expect { described_class.validate_theme!(valid_theme) }
        .to raise_error(Cvgen::SchemaError, /out of range/)
    end

    it "rejects invalid left_column_ratio" do
      valid_theme["spacing"] = valid_theme["spacing"].dup
      valid_theme["spacing"]["left_column_ratio"] = 0.05
      expect { described_class.validate_theme!(valid_theme) }
        .to raise_error(Cvgen::SchemaError, /left_column_ratio/)
    end

    it "rejects invalid scale" do
      valid_theme["scale"] = 2.0
      expect { described_class.validate_theme!(valid_theme) }
        .to raise_error(Cvgen::SchemaError, /scale/)
    end
  end

  describe ".validate_profile!" do
    it "requires a name" do
      expect { described_class.validate_profile!({ "layout" => "x" }) }
        .to raise_error(Cvgen::SchemaError, /name/)
    end

    it "accepts a named profile" do
      expect(described_class.validate_profile!({ "name" => "default" })).to be(true)
    end
  end

  describe ".validate_content!" do
    it "requires basics.name" do
      expect { described_class.validate_content!({ "basics" => { "name" => "" } }) }
        .to raise_error(Cvgen::SchemaError, /basics\.name/)
    end

    it "accepts content with a name" do
      expect(described_class.validate_content!({ "basics" => { "name" => "Ada" } })).to be(true)
    end
  end
end
