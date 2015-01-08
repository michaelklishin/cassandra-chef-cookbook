require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do

    # stub out the repo_server data bag
    server_node = {
      'id' => 'node',
      'ipaddress' => '0.0.0.0',
    }
    stub_search(:node, 'roles:opscenter_server').and_return([server_node])

  end

end

at_exit { ChefSpec::Coverage.report! }
