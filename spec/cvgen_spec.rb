# frozen_string_literal: true

RSpec.describe Cvgen do
  it "has a version number" do
    expect(Cvgen::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "exposes ROOT as an existing pathname" do
    expect(Cvgen::ROOT).to be_a(Pathname)
    expect(Cvgen::ROOT.join("lib/cvgen.rb")).to exist
  end
end
