module Importer

  module HTML

    # This methods takes a nokogiri node representing a table tag
    # and returns an array of attributes to be used to initialize or update records
    def html_table_to_hashes(table)

      raise ArgumentError unless table

      rows = []
      headers = []

      table.css('tr').each_with_index do |tr, index|

        if index == 0
          tr.xpath('td|th').each do |column|
            headers <<  column.content.strip.chomp
          end
        else
          row = {}
          tr.xpath('td|th').each_with_index do |column, index|

            # strip spaces, remove \n and replace non-breaking spaces with whitespace spaces
            row[headers[index].downcase.to_sym] = column.content.strip.chomp.gsub(/\u00a0/, "") if headers[index]
          end
          rows << row
        end
      end

      rows

    end

    # takes an HTML file as argument
    # creates a nokogiri doc, finds the first <table> tag inside
    # and passes the table to html_table_to_hashes
    def html_to_hashes(file)
      doc = Nokogiri::HTML(file)
      table = doc.css('table').first
      html_table_to_hashes table rescue {}
    end

  end

end