Gem::Specification.new do |s|
  s.name = %q{importer}
  s.version = "0.0.1"
  s.date = %q{2011-10-20}
  s.summary = %q{importer desc}
  s.authors = ["Crux Consulting"]
  s.files = [
    "VERSION",
    "lib/importer.rb",

    "lib/importer/action_dispatch_ext/http/to_attributes.rb",
    "lib/importer/action_dispatch_ext/http/to_attributes/csv.rb",
    "lib/importer/action_dispatch_ext/http/to_attributes/html.rb",

    "lib/importer/base.rb",
    "lib/importer/csv.rb",
    "lib/importer/html.rb",

    "samples/non-breaking-space.htm",

    "spec/spec_helper.rb",
    "spec/importer_spec.rb"
  ]
  
  s.require_paths = ["lib"]
end
