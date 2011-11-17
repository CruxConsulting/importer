require 'spec_helper'

describe ActionDispatch::Http::UploadedFile do

  let(:uploaded_file) do
    f = File.new(File.dirname(__FILE__) + "/../samples/ignore_col_span.htm")
    ActionDispatch::Http::UploadedFile.new :filename => "ignore_col_span.htm", :type => "text/html", :head => {}, :tempfile => f
  end
  subject { uploaded_file }

  it "does something" do
    uploaded_file.html_to_hashes.first.should == {
      :header_1 => "value_1",
      :header_2 => "value_2",
      :header_3 => "",
      :header_4 => "",
      :header_5 => "value_5",
      :header_6 => "",
      :header_7 => "",
      :header_8 => "",
      :header_9 => "value_9",
    }
  end
  
end