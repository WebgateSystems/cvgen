# frozen_string_literal: true

require "stringio"

RSpec.describe Cvgen::CLI do
  def run_cli(*args)
    described_class.start(args)
  end

  it "prints version" do
    expect { run_cli("version") }.to output(/cvgen #{Cvgen::VERSION}/).to_stdout
  end

  it "lists profiles from gem root" do
    expect { run_cli("list-profiles", "--root", Cvgen::ROOT.to_s) }
      .to output(/default/).to_stdout
  end

  it "lists themes and layouts" do
    expect { run_cli("list-themes", "--root", Cvgen::ROOT.to_s) }.to output(/default/).to_stdout
    expect { run_cli("list-layouts", "--root", Cvgen::ROOT.to_s) }.to output(/two-column/).to_stdout
  end

  it "validates fixture content without compiling" do
    Dir.mktmpdir do |dir|
      root = FixtureRoot.create(dir)
      root.join("content", "cv-junior.md").write(
        Cvgen::ROOT.join("spec/fixtures/cv-junior.md").read
      )

      expect do
        run_cli(
          "validate",
          "--root", root.to_s,
          "-c", "cv-junior",
          "-p", "default"
        )
      end.to output(/OK content=cv-junior\.md/).to_stdout
    end
  end
end
