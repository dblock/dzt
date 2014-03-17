require 'spec_helper'

describe DZT::Tiler do
  before :each do
    @fixtures_dir = File.expand_path(File.join(__FILE__, '../../fixtures'))
  end
  it "slices an image" do
    Dir.mktmpdir do |tmpdir|
      tiler = DZT::Tiler.new(
        source: File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg"),
        destination: tmpdir
      )
      tiler.slice!
      Dir["#{tmpdir}/*"].map { |dir| dir.split("/").last.to_i }.sort.should == (0..12).to_a
      # center
      image = Magick::Image::read("#{tmpdir}/11/1_1.jpg").first
      image.columns.should == 512
      image.rows.should == 512
      # edge
      image = Magick::Image::read("#{tmpdir}/11/2_2.jpg").first
      image.columns.should == 168
      image.rows.should == 443
    end
  end
end
