module DZT
  class FileStorage
    #
    # @param destination: Full directory in which to output tiles, defaults to 'tiles' in the current dir.
    #
    def initialize(options = {})
      @store_path = options[:destination] || File.join(Dir.pwd, 'tiles')
    end

    def exists?
      File.directory?(@store_path) && ! Dir["@{@store_path}/*"].empty?
    end

    def storage_location(level)
      File.join(@store_path, level.to_s)
    end

    def mkdir(path)
      FileUtils.mkdir_p(path)
    end

    def write(file, dest, options = {})
      quality = options[:quality]
      file.write(dest) { self.quality = quality if quality }
    end
  end
end