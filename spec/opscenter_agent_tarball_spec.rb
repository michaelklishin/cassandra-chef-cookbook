require 'spec_helper'

describe 'cassandra-dse::opscenter_agent_tarball' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
      node.set['cassandra']['opscenter']['agent']['download_url'] = 'test'
    end.converge(described_recipe)
  end

  it 'includes the ark recipe' do
    expect(chef_run).to include_recipe('ark')
  end

  it 'adds the opscenter_agent tarball' do
    expect(chef_run).to put_ark('opscenter_agent')
  end

  it 'adds the address.yaml conf file' do
    expect(chef_run).to create_template('/opt/opscenter_agent/conf/address.yaml')
  end

  it 'stats the opscenter agent service' do
    expect(chef_run).to start_service('opscenter-agent')
  end
end
