require "active_record"

require "importer"

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # see railscast #285
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

end