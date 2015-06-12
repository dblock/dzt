require 'spec_helper'
require 'RMagick'
include Magick

describe DZT do
  before :each do
    @binary = File.expand_path(File.join(__FILE__, '../../../bin/dzt'))
    @fixtures_dir = File.expand_path(File.join(__FILE__, '../../fixtures'))
  end
  describe '#help' do
    it 'displays help' do
      help = `"#{@binary}" help`
      expect(help).to include 'dzt - Tile images into deep-zoom tiles'
    end
  end
  describe '#slice' do
    it 'requires storage' do
      goya = File.join(@fixtures_dir, 'francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg')
      err = `"#{@binary}" slice #{goya} 2>&1`
      expect(err).to include 'error: You must specify either --output or --aws_id, --aws_secret and --bucket.'
    end
    context 'storing files locally' do
      it 'slices an image' do
        goya = File.join(@fixtures_dir, 'francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg')
        Dir.mktmpdir do |tmpdir|
          `"#{@binary}" slice "#{goya}" --output #{tmpdir}`
          expect(Dir["#{tmpdir}/*"].map { |dir| dir.split('/').last.to_i }.sort).to eq((0..12).to_a)
          # center
          image = Magick::Image.read("#{tmpdir}/11/1_1.jpg").first
          expect(image.columns).to eq(512)
          expect(image.rows).to eq(512)
        end
      end

      it 'correctly parses numeric options' do
        goya = File.join(@fixtures_dir, 'francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg')
        Dir.mktmpdir do |tmpdir|
          `"#{@binary}" slice "#{goya}" --output #{tmpdir} --quality=50`
          expect(Dir["#{tmpdir}/*"].map { |dir| dir.split('/').last.to_i }.sort).to eq((0..12).to_a)
          # center
          image = Magick::Image.read("#{tmpdir}/11/1_1.jpg").first
          expect(image.quality).to eq(50)
        end
      end
    end
    context 'uploading to S3' do
      pending 'slices the images and stores them'
    end
  end
end
