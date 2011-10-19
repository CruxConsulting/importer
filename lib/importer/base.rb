require "active_support/inflector/inflections"

require "importer/csv"
require "importer/html"

module Importer

  class Base

    extend Importer::CSV
    extend Importer::HTML

    # Class methods
    ###############

    class << self

      # This method is in charge of determining the model the importer will use to build records
      # By convention, the importer must be named with the model name in its plural form
      # followed by Importer
      #
      # ie : to build an importer for the Employee model, you will create the class
      # class EmployeesImporter < Importer
      def attached_model
        plural = self.to_s.gsub('Importer', '')
        raise "The Importer class is abstract. You must inherit from it : ie EmployeesImporter" if plural.blank?
        plural.singularize.constantize
      end

      # this method takes a content_type string as argument
      # ie : "text/html" or "text/csv"
      # and returns the method sym that should be used to convert the file's content
      # in attributes hashes to be used for model creation or updates
      def content_type_to_attributes_method(content_type)
        [content_type.split('/').last, "to_hashes"].join('_').to_sym
      end

      # Take a file, uses its content_type to dertermine what method
      # will be used to extract data
      #
      # returns an array of attributes hashes
      def file_to_hashes(file)
        method = content_type_to_attributes_method(file.content_type)
        attributes_array = self.send(method, file)
      end

      # override this methods to update the nested attribs with their respective record id
      def prepare_nested_attributes(object, attributes)
        attributes
      end

    end

    # Instance methods
    ##################

    attr_reader :created_count, :updated_count

    def initialize(import)
      @import = import
      @created_count = 0
      @updated_count = 0
    end

    # TODO : more doc and refactor ...
    # This method uses the attributes_array to initialize, update or build discards
    def import

      attributes_array = self.class.file_to_hashes(@import.file)
      attributes_array.each do |attributes|

        object = find_or_initialize_object(attributes)

        if object.persisted?
          attribs = self.class.prepare_nested_attributes(object, attributes)
          object.update_attributes(attribs) ? @updated_count += 1 : build_discard(object)
        else
          set_missing_attributes(object)
          object.save ? @created_count += 1 : build_discard(object)
        end

        after_import(object)

      end

    end

    # Protected methods
    ###################

    protected

    def set_missing_attributes(object)
    end

    def after_import(object)
    end

    # This method is in charge of building a discard object with the correct description
    def build_discard(object)

      descriptions = []
      object.errors.each do |attribute, message|
        descriptions << [self.class.attached_model.human_attribute_name(attribute), message].join(' ') unless attribute == :firm_id
      end
      @import.discards.build(:identifier => object.send(self.find_by_attribute), :description => descriptions.join("\n"))

      # @import.discards.build(
      #   :identifier => object.send(self.find_by_attribute),
      #   :description => object.errors.full_messages.map(&:capitalize).join("\n")
      # )
    end

    # This method uses the find_by_attribute symbol to find an existing record to be updated by the importer
    #
    # If no record could be found, initializes a new record with the attributes given as argument
    def find_or_initialize_object(attributes)
      self.class.attached_model.where(find_by_attribute => attributes[find_by_attribute].try(:strip)).first || self.class.attached_model.new(attributes)
    end

  end

end