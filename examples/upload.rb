$LOAD_PATH.unshift(File.expand_path('../lib'))
require 'balloon'

Balloon.configure do |config|
  config.store_storage = :file
  config.root = "output"
end

class Upload < Balloon::Base
  uploader :image
  uploader_dir 'uploads'
  uploader_mimetype_white %w[image/jpeg image/png image/gif image/webp]
  uploader_name_format name: "output", format: 'upcase'
  uploader_type_format 'webp'
  uploader_size thumb: '200x', small: '600x>', large: '800x>'
end

upload = Upload.new("input.jpg")
upload.upload_store
