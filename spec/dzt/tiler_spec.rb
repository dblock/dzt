require 'spec_helper'
require 'RMagick'
include Magick

describe DZT::Tiler do
  before :each do
    @fixtures_dir = File.expand_path(File.join(__FILE__, '../../fixtures'))
  end
  context 'storing files locally' do
    it "slices an image and stores files" do
      Dir.mktmpdir do |tmpdir|
        storage = DZT::FileStorage.new(destination: tmpdir)
        tiler = DZT::Tiler.new(
          source: File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg"),
          storage: storage
        )
        tiler.slice!
        expect(Dir["#{tmpdir}/*"].map { |dir| dir.split("/").last.to_i }.sort).to eq((0..12).to_a)
        # center
        image = Magick::Image::read("#{tmpdir}/11/1_1.jpg").first
        expect(image.columns).to eq(512)
        expect(image.rows).to eq(512)
        expect(image.quality).to eq(75)
        # edge
        image = Magick::Image::read("#{tmpdir}/11/2_2.jpg").first
        expect(image.columns).to eq(168)
        expect(image.rows).to eq(443)
        expect(image.quality).to eq(75)
      end
    end
  end
  context 'uploading resultant files to S3' do
    before :each do
      Fog.mock!
      Fog::Mock.reset
      storage = DZT::S3Storage.new(
        s3_acl: 'public-read',
        s3_bucket: 'tiled-images',
        s3_key: 'dztiles',
        aws_id: 'id',
        aws_secret: 'secret'
      )
      @bucket = storage.s3.directories.create(key: 'tiled-images')
      @tiler = DZT::Tiler.new(
        source: File.join(@fixtures_dir, "francisco-jose-de-goya-y-lucientes-senora-sabasa-garcia.jpg"),
        storage: storage
      )
    end
    it 'slices the images' do
      @tiler.slice!
      file = @bucket.files.select { |f| f.key == 'dztiles/11/1_1.jpg' }.first
      image = Image.from_blob(file.body).first
      expect(image.columns).to eq(512)
      expect(image.rows).to eq(512)
      file = @bucket.files.select { |f| f.key == 'dztiles/11/2_2.jpg' }.first
      image = Image.from_blob(file.body).first
      expect(image.columns).to eq(168)
      expect(image.rows).to eq(443)
    end
    it 'stores the files properly' do
      expect_any_instance_of(Fog::Storage::AWS::Mock).to receive(:put_object).at_least(53).times do |*args|
        expect(args.last).to eq("Content-Type" => "image/jpeg", "x-amz-acl" => "public-read")
      end
      @tiler.slice!
    end
  end
end
