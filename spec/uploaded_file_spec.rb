require 'spec_helper'

describe ActionDispatch::Http::UploadedFile do

  let(:uploaded_file) do
    f = File.new(File.dirname(__FILE__) + "/../samples/#{filename}")
    ActionDispatch::Http::UploadedFile.new :filename => filename, :type => "text/html", :head => {}, :tempfile => f
  end
  subject { uploaded_file }

  context "uploaded_file containing TDs with colspan values" do
    let(:filename) { "ignore_col_span.htm" }

    it "creates empty TDs to replace colspans" do
      uploaded_file.html_to_hashes.first.should == {
        :header_1 => "value_1",
        :header_2 => "value_2",
        :header_3 => nil,
        :header_4 => nil,
        :header_5 => "value_5",
        :header_6 => nil,
        :header_7 => nil,
        :header_8 => nil,
        :header_9 => "value_9",
      }
    end
  end

  context "uploaded_file with empty cells" do
    let(:filename) { "empty_cells.htm"}

    it "replaces blank cells by nil" do
      uploaded_file.html_to_hashes.first.should == { :header_1 => nil }
    end
  end
  
  context "uploaded_file with non-breaking spaces" do
    let(:filename) { "non-breaking-space.htm"}

    it "replaces non-breaking spaces" do
      uploaded_file.html_to_hashes.first.should == { :header_1 => "after nbsp" }
    end

  end  

end