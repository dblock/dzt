require 'spec_helper'
require 'RMagick'
include Magick

describe DZT do
  before :each do
    @binary = File.expand_path(File.join(__FILE__, '../../../bin/dzt'))
    @fixtures_dir = File.expand_path(File.join(__FILE__, '../../fixtures'))
  end
  describe "#help" do
    it "displays help" do
      help = `"#{@binary}" help`
      expect(help).to include "dzt - Tile images into deep-zoom tiles"
    end
  end
  describe "#slice" do
    context 'storing files locally' do
      it "slices an image" do
        goya = File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg")
        Dir.mktmpdir do |tmpdir|
          `"#{@binary}" slice "#{goya}" --output #{tmpdir}`
          expect(Dir["#{tmpdir}/*"].map { |dir| dir.split("/").last.to_i }.sort).to eq((0..12).to_a)
          # center
          image = Magick::Image::read("#{tmpdir}/11/1_1.jpg").first
          expect(image.columns).to eq(512)
          expect(image.rows).to eq(512)
        end
      end

      it "correctly parses numeric options" do
        goya = File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg")
        Dir.mktmpdir do |tmpdir|
          `"#{@binary}" slice "#{goya}" --output #{tmpdir} --quality=50`
          expect(Dir["#{tmpdir}/*"].map { |dir| dir.split("/").last.to_i }.sort).to eq((0..12).to_a)
          # center
          image = Magick::Image::read("#{tmpdir}/11/1_1.jpg").first
          expect(image.quality).to eq(50)
        end
      end
    end
    context 'uploading to S3' do
      before :each do
        Fog.mock!
        Fog::Mock.reset
        s3 = Fog::Storage.new(
          provider: 'AWS',
          aws_access_key_id: 'id',
          aws_secret_access_key: 'secret'
        )
        @bucket = s3.directories.create(key: 'tiled-images')
      end
      xit 'slices the images and stores them' do
        goya = File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg")
        expect_any_instance_of(Fog::Storage::AWS::Mock).to receive(:put_object).at_least(53).times do |*args|
          expect(args.last).to eq("Content-Type" => "image/jpeg", "x-amz-acl" => "public-read")
        end
        `"#{@binary}" slice "#{goya}" --acl=public-read --bucket=tiled-images --s3-key=dztiles --aws-id=id --aws-secret=secret`
        file = @bucket.files.select { |f| f.key == 'dztiles/11/1_1.jpg' }.first
        image = Image.from_blob(file.body).first
        expect(image.columns).to eq(512)
        expect(image.rows).to eq(512)
        file = @bucket.files.select { |f| f.key == 'dztiles/11/2_2.jpg' }.first
        image = Image.from_blob(file.body).first
        expect(image.columns).to eq(168)
        expect(image.rows).to eq(443)
      end
    end
  end
end
