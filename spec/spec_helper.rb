require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the path for Chef to find roles (default: [ascending search])
  # config.role_path = "/var/roles"

  # Specify the Chef log_level (default: :warn)
  # config.log_level = :info

  # Specify the path to a local JSON file with Ohai data (default: nil)
  # config.path = "ohai.json"

  # Specify the operating platform to mock Ohai data from (default: nil)
  config.platform = 'centos'

  # Specify the operating version to mock Ohai data from (default: nil)
  config.version = '6.4'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

at_exit { ChefSpec::Coverage.report! }
