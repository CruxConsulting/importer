require "csv"

module ActionDispatch
  module Http
    module ToAttributes
      module CSV

        def csv_to_hashes
          rows = []

          ::CSV.foreach(tempfile.path, :headers => true, :col_sep => ";", encoding: "UTF-8") do |row|
            rows << row.to_hash.symbolize_keys
          end

          rows
        end

      end
    end
  end
end