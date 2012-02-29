require 'spec_helper'

class A
  include Importer::ActiveRecord::NestAttributes
end

class Service
  include Importer::ActiveRecord::NestAttributes
end
#
# class SubService < ActiveRecord::Base
# end

describe "nest attributes" do

  it "first example" do
    a = A.new

    A.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:services) {[]}

    nested_attributes = a.nest_attributes({service_1_name: "s1"})
    nested_attributes["services_attributes"]["1"]["name"].should == "s1"
  end

end