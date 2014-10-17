# Deep Zoom module for generating Deep Zoom (DZI) tiles from a source image
require_relative 'file_storage'
require_relative 's3_storage'
module DZT
  class Tiler
    # Defaults
    DEFAULT_TILE_SIZE = 512
    DEFAULT_TILE_OVERLAP = 0
    DEFAULT_QUALITY = 75
    DEFAULT_TILE_FORMAT = "jpg"
    DEFAULT_OVERWRITE_FLAG = false

    # Generates the DZI-formatted tiles and sets necessary metadata on this object.
    #
    # @param source Magick::Image, or filename of image to be used for tiling
    # @param quality Image compression quality (default: 75)
    # @param format Format for output tiles (default: "jpg")
    # @param size Size, in pixels, for tile squares (default: 512)
    # @param overlap Size, in pixels, of the overlap between tiles (default: 2)
    # @param overwrite Whether or not to overwrite if the destination exists (default: false)
    # @param storage Either an instance of S3Storage or FileStorage
    #
    def initialize(options)
      @tile_source = options[:source]
      raise "Missing options[:source]." unless @tile_source

      @tile_source = Magick::Image.read(@tile_source)[0] if @tile_source.is_a?(String)
      @tile_size = options[:size] || DEFAULT_TILE_SIZE
      @tile_overlap = options[:overlap] || DEFAULT_TILE_OVERLAP
      @tile_format  = options[:format] || DEFAULT_TILE_FORMAT

      @max_tiled_height = @tile_source.rows
      @max_tiled_width = @tile_source.columns

      @tile_quality = options[:quality] || DEFAULT_QUALITY
      @overwrite = options[:overwrite] || DEFAULT_OVERWRITE_FLAG
      @storage = options[:storage]
    end

    ##
    # Generates the DZI-formatted tiles and sets necessary metadata on this object.
    # Uses a default tile size of 512 pixels, with a default overlap of 2 pixel.
    ##
    def slice!(&block)
      raise "Output #{@destination} already exists!" if ! @overwrite && @storage.exists?

      image = @tile_source.dup
      orig_width, orig_height = image.columns, image.rows

      # iterate over all levels (= zoom stages)
      max_level(orig_width, orig_height).downto(0) do |level|
        width, height = image.columns, image.rows

        current_level_storage_dir = @storage.storage_location(level)
        @storage.mkdir(current_level_storage_dir)
        if block_given?
          yield current_level_storage_dir
        end

        # iterate over columns
        x, col_count = 0, 0
        while x < width
          # iterate over rows
          y, row_count = 0, 0
          while y < height
            dest_path = File.join(current_level_storage_dir, "#{col_count}_#{row_count}.#{@tile_format}")
            tile_width, tile_height = tile_dimensions(x, y, @tile_size, @tile_overlap)

            save_cropped_image(image, dest_path, x, y, tile_width, tile_height, @tile_quality)

            y += (tile_height - (2 * @tile_overlap))
            row_count += 1
          end
          x += (tile_width - (2 * @tile_overlap))
          col_count += 1
        end

        image.resize!(0.5)
      end

      image.destroy!
    end

    protected

    # Determines width and height for tiles, dependent of tile position.
    # Center tiles have overlapping on each side.
    # Borders have no overlapping on the border side and overlapping on all other sides.
    # Corners have only overlapping on the right and lower border.
    def tile_dimensions(x, y, tile_size, overlap)
      overlapping_tile_size = tile_size + (2 * overlap)
      border_tile_size      = tile_size + overlap

      tile_width  = (x > 0) ? overlapping_tile_size : border_tile_size
      tile_height = (y > 0) ? overlapping_tile_size : border_tile_size

      return tile_width, tile_height
    end

    # Calculates how often an image with given dimension can
    # be divided by two until 1x1 px are reached.
    def max_level(width, height)
      return (Math.log([width, height].max) / Math.log(2)).ceil
    end

    # Crops part of src image and writes it to dest path.
    #
    # Params: src: may be an Magick::Image object or a path to an image.
    #         dest: path where cropped image should be stored.
    #         x, y: offset from upper left corner of source image.
    #         width, height: width and height of cropped image.
    #         quality: compression level 0-100 (or 0.0-1.0), lower number means higher compression.
    def save_cropped_image(src, dest, x, y, width, height, quality = 75)
      if src.is_a? Magick::Image
        img = src
      else
        img = Magick::Image::read(src).first
      end

      quality = quality * 100 if quality < 1

      # The crop method retains the offset information in the cropped image.
      # To reset the offset data, adding true as the last argument to crop.
      cropped = img.crop(x, y, width, height, true)
      @storage.write(cropped, dest, quality: quality)
    end
  end
end
