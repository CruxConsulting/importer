module Importer
  module ActiveRecord
    module NestAttributes
      
      def nest_attributes(flat_attributes)
        
        flat_attributes.inject(nested_attributes = {}) do |memo, pair|

          key, v = pair.first, pair.last

          unless key =~ /^(course|service|sub_service)_(\d+)_(.+)/
            memo[key] = v
          else
            nested_key = "#{$1.pluralize}_attributes"
            index = $2
            sub_key = $3

            memo[nested_key] ||= {}
            memo[nested_key][index] ||= {}
            memo[nested_key][index].deep_merge!(nest_attributes(sub_key => v))
          end

          memo
        end

      end
      
    end
    
    ::ActiveRecord::Base.extend(NestAttributes)
  end
end