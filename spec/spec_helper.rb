require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

at_exit { ChefSpec::Coverage.report! }
