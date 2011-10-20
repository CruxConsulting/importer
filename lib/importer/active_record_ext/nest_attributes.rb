module Importer
  module ActiveRecord
    module NestAttributes

      def nest_attributes(flat_attributes)

        flat_attributes.inject(nested_attributes = {}) do |memo, pair|

          key, v = pair.first, pair.last

          possible_keys = nested_attributes_options.keys.map { |key| key.to_s.singularize }.join('|')
          unless key =~ /^(#{possible_keys})_(\d+)_(.+)/
            memo[key] = v
          else
            nested_key = "#{$1.pluralize}_attributes"
            index = $2
            sub_key = $3

            memo[nested_key] ||= {}
            memo[nested_key][index] ||= {}

            sub_attributes = begin
              $1.camelize.constantize.nest_attributes(sub_key => v)
            rescue NameError
              {sub_key => v}
            end

            memo[nested_key][index].deep_merge! sub_attributes
          end

          memo
        end

      end

    end

    ::ActiveRecord::Base.extend(NestAttributes)
  end
end