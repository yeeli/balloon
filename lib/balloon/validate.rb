require 'active_model/validator'

module Balloon
  module Validate
    extend ActiveSupport::Concern

    included do
      extend HelperMethods
      include HelperMethods
    end

    class DownloadValidator < ActiveModel::EachValidator
      def validate_each(record, attr_name, value)
        if e = record.send(:download_error)
          message = (e.message == e.class.to_s) ? :download_error : e.message
          record.errors.add(attr_name, message)
        end
      end
    end

    class ProcessValidator < ActiveModel::EachValidator
      def validate_each(record, attr_name, value)
        if e = record.send(:process_error)
          message = (e.message == e.class.to_s) ? :process_error : e.message
          record.errors.add(attr_name, message)
        end
      end
    end

    module HelperMethods
      def validates_download_of(*attr_names)
        validates_with DownloadValidator, _merge_attributes(attr_names)
      end

      def validates_process_of(*attr_names)
        validates_with ProcessValidator, _merge_attributes(attr_names)
      end
    end
  end
end

