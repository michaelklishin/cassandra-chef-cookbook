require 'spec_helper'

describe 'cassandra-dse' do
  context "seeds assigned as an array to node['cassandra']['seeds']" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['seeds'] = %w[seed1 seed2]
      end.converge(described_recipe)
    end

    it 'renders the /etc/cassandra/cassandra.yaml with seeds: seed1,seed2' do
      expect(chef_run).to render_file('/etc/cassandra/cassandra.yaml')
        .with_content('- seeds: seed1,seed2')
    end
  end

  context "seeds assigned as an string to node['cassandra']['seeds']" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['seeds'] = 'seed1,seed2'
      end.converge(described_recipe)
    end

    it 'renders the /etc/cassandra/cassandra.yaml with seeds: seed1,seed2' do
      expect(chef_run).to render_file('/etc/cassandra/cassandra.yaml')
        .with_content('- seeds: seed1,seed2')
    end
  end

  # TODO: Why doesn't the stub work?
  # context 'seeds selected through a chef search' do
  #   cached(:chef_run) do
  #     ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node, server|
  #       node.override['cassandra']['config']['cluster_name'] = 'chefspec'
  #       node.override['cassandra']['seed_discovery']['use_chef_search'] = true
  #       node.override['chef_environment'] = 'chefspec'
  #     end.converge(described_recipe)
  #   end

  #   it 'renders the /etc/cassandra/cassandra.yaml with seeds: seed1,seed2' do
  #     stub_search(:node, 'chef_environment:_default AND role:cassandra-seed AND cassandra_cluster_name:chefspec')
  #       .and_return([{seed1: {ipaddress: '10.10.10.10'}, seed2: {ipaddress: '10.10.10.11'}}])
  #     expect(chef_run).to render_file('/etc/cassandra/cassandra.yaml')
  #       .with_content('- seeds: 10.10.10.10,10.10.10.11')
  #   end
  # end
end
