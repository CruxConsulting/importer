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

    module PrepareNestesAttributes

      def prepare_nested_attributes(attributes)
        h = {}

        attributes.each do |k, v|

          if k == "services_attributes"

            v.each do |s_k, s_v|

              s = services.detect {|s| s.name == s_v["name"]}

              if s

                h["services_attributes"] ||= {}
                h["services_attributes"][s_k] ||= {}
                h["services_attributes"][s_k] = s_v.merge({"id" => s.id.to_s})

                s_v.each do |sss_k, sss_v|
                  if sss_k == "sub_services_attributes"

                    sss_v.each do |ss_k, ss_v|
                      ss = s.sub_services.detect {|ss| ss.name == ss_v["name"]}

                      if ss
                        h["services_attributes"] ||= {}
                        h["services_attributes"][s_k] ||= {}
                        h["services_attributes"][s_k]["sub_services_attributes"] ||= {}
                        h["services_attributes"][s_k]["sub_services_attributes"][ss_k] = ss_v.merge({"id" => ss.id.to_s})
                      else
                        h["services_attributes"][s_k] ||= {}
                        h["services_attributes"][s_k].merge(s_v)
                      end

                    end

                  else
                    h["services_attributes"] ||= {}
                    h["services_attributes"][s_k] ||= {}
                    h["services_attributes"][s_k][sss_k] = sss_v
                  end
                end

              else
                h[k] ||= {}
                h[k].merge!(v)
              end

            end
          elsif k == "courses_attributes"

            v.each do |s_k, s_v|

              course = courses.detect {|c| c.name == s_v["name"]}

              if course
                h["courses_attributes"] ||= {}
                h["courses_attributes"][s_k] ||= {}
                h["courses_attributes"][s_k] = s_v.merge({"id" => course.id.to_s})
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

  end
end

class ActiveRecord::Base
  extend Importer::ActiveRecord::NestAttributes
  include Importer::ActiveRecord::PrepareNestesAttributes
end