gem "actionpack"
require "action_dispatch"
require "active_support/core_ext/string/encoding"
require "active_support/core_ext/hash/keys"

require "importer/action_dispatch_ext/http/to_attributes/csv"
require "importer/action_dispatch_ext/http/to_attributes/html"

module ActionDispatch
  module Http

    module ToAttributes

      include CSV
      include HTML

      def to_attributes
        method = content_type_to_attributes_method
        attributes_array = self.send method
      end

      # this method takes a content_type string as argument
      # ie : "text/html" or "text/csv"
      # and returns the method sym that should be used to convert the file's content
      # in attributes hashes to be used for model creation or updates
      def content_type_to_attributes_method
        {
          "text/html"                   => :html_to_hashes,
          "text/csv"                    => :csv_to_hashes,
          "text/plain"                  => :csv_to_hashes,
          "application/octet-stream"    => :csv_to_hashes,
          "text/comma-separated-values" => :csv_to_hashes,
          "application/vnd.ms-excel"    => :csv_to_hashes
        }[content_type]
      end
      private :content_type_to_attributes_method

    end

    class UploadedFile
      include ToAttributes
    end

  end
end