require 'spec_helper'

class A
  include Importer::ActiveRecord::NestAttributes
end

class Service
  include Importer::ActiveRecord::NestAttributes
end

class SubService
  include Importer::ActiveRecord::NestAttributes
end

describe "nest attributes module" do

  it "should nest valid attributes" do
    a = A.new

    A.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:services) {[]}

    nested_attributes = a.nest_attributes({service_1_name: "s1"})
    nested_attributes["services_attributes"]["1"]["name"].should == "s1"
  end

  it "should add :id key for existing records" do
    a = A.new

    A.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:nested_attributes_options) { {services: {}}}
    service_double = double(id: 100, name: "s1", nest_attributes: {"name"=>"s1"})
    a.stub(:services) {[service_double]}

    service_double.should_receive(:id)
    nested_attributes = a.nest_attributes({service_1_name: "s1"})
    nested_attributes["services_attributes"]["1"]["id"].should == "100"
  end

  it "should deep nest attributes" do
    a = A.new

    A.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:nested_attributes_options) { {services: {}}}
    a.stub(:services) {[]}

    Service.stub(:nested_attributes_options) { {sub_services: {}}}

    nested_attributes = a.nest_attributes({
      service_1_name: "s1",
      service_1_sub_service_1_name: "ss1"
    })
    nested_attributes["services_attributes"]["1"]["sub_services_attributes"]["1"]["name"].should == "ss1"
  end

end