require 'spec_helper'

describe Importer::Base do

  let(:file) do
    file = File.open(File.dirname(__FILE__) + "/../samples/non-breaking-space.htm")
    file.stub(:content_type).and_return("text/html")
    file
  end

  describe ".html_table_to_hashes" do

    it "replaces non-breaking spaces with regular spaces" do
      Importer::Base.html_to_hashes(file).first[:name].should == " "
    end

  end

end