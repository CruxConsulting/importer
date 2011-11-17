module Importer
  module ActiveRecord
    module NestAttributes
      
      module ClassMethods

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

      module InstanceMethods
        
        def nest_attributes(flat_attributes)
          
          attribs = self.class.nest_attributes flat_attributes
          
          h = {}

          attribs.each do |k, v|

            possible_nested_keys = nested_attributes_options.keys.map { |key| "#{key}_attributes" }

            if possible_nested_keys.include? k
              
              association = k.gsub("_attributes", "")
              v.each do |s_k, s_v|

                associated_object = self.send(association).detect {|s| s.name == s_v["name"]}

                if associated_object
                  h[k] ||= {}
                  h[k][s_k] ||= {}
                  h[k][s_k] = associated_object.nest_attributes(s_v).merge({"id" => associated_object.id.to_s})
                else
                  h[k] ||= {}
                  h[k].merge!(v)
                end

              end
            else
              h[k] = v
            end

          end

          h
        end        
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
      
    end

  end
end

class ::ActiveRecord::Base
  include Importer::ActiveRecord::NestAttributes
end