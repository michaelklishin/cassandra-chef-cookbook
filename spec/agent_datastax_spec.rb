require 'spec_helper'

describe 'cassandra-dse::opscenter_agent_datastax' do

  let(:chef_run) do

    ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|

      node.set['cassandra']['cluster_name'] = 'test'
      node.set['cassandra']['version'] = '2.1.7'
      node.set['cassandra']['install_java'] = true
      node.set['cassandra']['yum']['options'] = '--always-have-options'

    end.converge(described_recipe)

  end

  it 'includes dependent recipes' do
    expect(chef_run).to include_recipe 'java'
    expect(chef_run).to include_recipe 'cassandra-dse::repositories'
  end

  it 'installs the agent package' do
    expect(chef_run).to install_package('datastax-agent').with(options: '--always-have-options')
  end

  it 'starts & enables the service' do
    expect(chef_run).to enable_service('datastax-agent')
    expect(chef_run).to start_service('datastax-agent')
  end

  it 'renders the agent config file' do
    expect(chef_run).to create_template('/var/lib/datastax-agent/conf/address.yaml')
  end

end
