require "csv"

module ActionDispatch
  module Http
    module ToAttributes
      module HTML

        # This methods takes a nokogiri node representing a table tag
        # and returns an array of attributes to be used to initialize or update records
        def html_table_to_hashes(table)

          raise ArgumentError unless table

          rows = []
          headers = []

          complement_tds_with_colspan(table)

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
        def html_to_hashes
          doc = Nokogiri::HTML(tempfile)
          table = doc.css('table').first
          html_table_to_hashes table rescue {}
        end
        
        private
        
        # Excel's export does not output one TD for each header when some cells are empty
        # Insted, it generates one TD with a colspan attribute and adds the "mso-ignore:colspan" style
        # to render it correctly when you re-open the html file with excel
        #
        # Because of this, we don't have the same number of header TDs and value TDs which break to attributes
        # generation
        #
        # To avoid this, we find all TDs with a colspan attribute and add as many empty TDs after then
        # as needed by the colspan value
        #
        # ie : one TD with a colspan of 3 will have 2 new empty TDs added after
        def complement_tds_with_colspan(table)
          table.css("td[colspan]").each do |td_with_colspan|
            
            new_tds_needed = td_with_colspan["colspan"].to_i - 1
            
            new_tds_needed.times do
              td_with_colspan.after Nokogiri::XML::Node.new 'td', table.document
            end
          end
          
        end

      end
    end
  end
end