module Importer

  module CSV

    # This methods takes a csv file
    # and returns an array of attributes to be used to initialize or update records
    def csv_to_hashes(file)
      rows = []

      ::CSV.foreach(file.path, :headers => true, :col_sep => ";") do |row|
        rows << row.to_hash.symbolize_keys
      end

      rows
    end
  end

end