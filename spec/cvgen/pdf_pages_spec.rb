# frozen_string_literal: true

RSpec.describe Cvgen::PdfPages do
  it "counts /Type /Page markers" do
    Dir.mktmpdir do |dir|
      path = Pathname(dir).join("x.pdf")
      path.binwrite("%PDF-1.4\n/Type /Page\n/Type /Page\n/Type /Pages\n")
      expect(described_class.count(path)).to eq(2)
    end
  end

  it "falls back to /Count when page markers are missing" do
    Dir.mktmpdir do |dir|
      path = Pathname(dir).join("x.pdf")
      path.binwrite("%PDF-1.4\n/Count 3\n")
      expect(described_class.count(path)).to eq(3)
    end
  end

  it "defaults to 1 when nothing matches" do
    Dir.mktmpdir do |dir|
      path = Pathname(dir).join("x.pdf")
      path.binwrite("%PDF-1.4 empty")
      expect(described_class.count(path)).to eq(1)
    end
  end
end
