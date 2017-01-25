require 'spec_helper'

describe 'cassandra-dse::default' do
  context 'Centos 6.4 - yum - dsc20' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.0.11'
        node.override['cassandra']['package_name'] = 'dsc20'
      end.converge(described_recipe)
    end

    it 'adds the datastax repository' do
      expect(chef_run).to create_yum_repository('datastax')
    end
  end

  context 'Centos 6.4 - yum - dsc21' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.1.7'
        node.override['cassandra']['package_name'] = 'dsc21'
      end.converge(described_recipe)
    end

    it 'adds the datastax repository' do
      expect(chef_run).to create_yum_repository('datastax')
    end
  end

  context 'Ubuntu 12.04 - apt - cassandra 2.0.11' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.0.11'
        node.override['cassandra']['package_name'] = 'dsc20'
      end.converge(described_recipe)
    end

    it 'adds the datastax repository' do
      expect(chef_run).to add_apt_repository('datastax')
    end

    it 'installs the apt-transport-https package' do
      expect(chef_run).to install_package('apt-transport-https')
    end
  end
end
