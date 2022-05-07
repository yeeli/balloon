require 'mime/types'
require 'pathname'

module Balloon
  # This class is file Extension for ruby class
  #
  # @param[File, UploadFile, Hash, String, StringIO] file
  #
  # @example
  #
  # file = FileExtension.new(file)
  # file.path 
  # file.filename 
  # file.basename 
  # file.mime_type
  # file.extension
  # file.read
  #

  class FileExtension
    SANITIZE_REGEX = /[^a-zA-Z0-9\.]|[\^]/

    FILENAME_REGEX = [ /\A(.+)\.(tar\.([glxb]?z|bz2))\z/, /\A(.+)\.([^\.]+)\z/ ]

    IMAGE_REGEX =  [
      ["GIF8", "image/gif"],
      ["\x89PNG", "image/png"],
      ["\xff\xd8\xff\xe0\x00\x10JFIF", "image/jpeg"],
      ["\xff\xd8\xff\xe1(.*){2}Exif", "image/jpeg"]
    ]

    IMAGE_EXT_LIST = { 
      "image/gif" => "gif",
      "image/jpeg" => "jpg",
      "image/png" => "png",
      "image/webp" => "webp"
    }

    def initialize(file, mime_type = nil)
      if file.is_a?(Hash)
        @file = file["tempfile"] || file[:tempfile]
        @original_filename = file["filename"] || file[:filename]
        @mime_type = file["content_type"] || file[:content_type]
      else
        @file = file
        @original_filename = nil
        @mime_type = mime_type
      end
    end

    # Get real path with uploaded file
    #
    # @return [String] file path
    def path
      return "" if @file.blank?
      if @file.is_a?(String) || @file.is_a?(Pathname)
        File.expand_path(@file)
      elsif @file.respond_to?(:path)
        File.expand_path(@file.path)
      else
        ""
      end
    end

    # Get original filename with uploaded file
    #
    # @return [String] file original filename 
    def original_filename
      return @original_filename if @original_filename
      if @file && @file.respond_to?(:original_filename)
        @file.original_filename
      elsif !path.blank?
        File.basename(path)
      else
        ""
      end
    end

    # Get filename with uploaded file
    #
    # @return [string] the real filename
    def filename
      return "" if original_filename.blank?
      sanitize(original_filename) 
    end

    def basename
      return "" if filename.blank?
      split_extension(filename)[0] 
    end

    def extension
      ext_name = split_extension(filename)[1] if !filename.blank?
      return ext_name if !ext_name.blank?
      return IMAGE_EXT_LIST[mime_type]
    end

    def mime_type
      return get_mime_type(MIME::Types[@mime_type]) if @mime_type
      ext_name = split_extension(filename)[1] if !filename.blank?
      return get_mime_type(MIME::Types.type_for(ext_name)) if !ext_name.blank? 
      if type = read_mime_type then return type end
      if type = command_mime_type then return type end
    end

    def size
      return 0 if @file.blank?
      if @file.is_a?(String)
        exists? ? File.size(path) : 0
      elsif @file.respond_to?(:size)
        @file.size
      else
        0
      end
    end

    def empty?
      @file.nil? || self.size.nil? || ( self.size.zero? && !self.exists? )
    end

    def exists?
      return File.exists?(self.path) if !path.empty?
      return false
    end

    def read(count = nil)
      return "" if empty?
      if exists? && @file.is_a?(String)
        File.open(@file, "rb") {|file| file.read(count) }
      elsif @file.respond_to?(:read)
        @file.read(count)
      else
        ""
      end
    end

    def self.get_extension(mime_type)
      IMAGE_EXT_LIST[mime_type]
    end

    # @todo What Change basename add extension
    def save_to(new_path, permissions = nil, directory_permission = nil)
      new_path = File.expand_path new_path
      new_path = File.join new_path, basename + "." + extension 

      if exists?
        FileUtils.cp(path, new_path) unless new_path == path
      else
        File.open(new_path, "wb"){ |f| f.write(read) }
      end
      File.chmod(permissions, new_path) if permissions
      self.class.new(new_path)
    end

    private

    def sanitize(name)
      name = name.gsub("\\", "/")
      name = name.gsub(SANITIZE_REGEX, "_") 
      name = "_#{name}" if name =~ /\A\.+\z/
      name = "unnamed" if name.size == 0
      #name = name.downcase
      return name.mb_chars.to_s
    end

    def split_extension(filename)
      FILENAME_REGEX.each do |regexp|
        return $1, $2 if filename =~ regexp
      end
      return filename, ""
    end

    def get_mime_type(mime_type)
      mime_type.first.content_type if !mime_type.empty?
    end

    def read_mime_type
      content = read(10)
      return if content.blank?
      IMAGE_REGEX.each do |regexp|
        return regexp[1] if content =~ %r"^#{regexp[0].force_encoding("binary")}"
      end
      return nil
    end

    def command_mime_type
      content = `file #{path} --mime-type`.gsub("\n", '')
      content.split(':')[1].strip if content
    end
  end   
end
