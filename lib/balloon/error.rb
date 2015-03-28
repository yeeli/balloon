module Balloon
  class UploadError < StandardError; end
  class DownloadError < UploadError; end
  class ProcessError < UploadError; end
end
