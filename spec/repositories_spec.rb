require 'spec_helper'

describe 'cassandra-dse::repositories' do
  context 'Centos 7.0' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
      end.converge(described_recipe)
    end

    it 'adds the datastax repository' do
      expect(chef_run).to create_yum_repository('datastax').with(
        baseurl: 'http://rpm.datastax.com/community',
        description: 'DataStax Repo for Apache Cassandra',
        gpgcheck: false,
        enabled: true
      )
    end
  end

  context 'Ubuntu 16.04' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
      end.converge(described_recipe)
    end

    it 'installs the apt-transport-https package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'adds the datastax repository' do
      expect(chef_run).to add_apt_repository('datastax').with(
        uri: 'https://debian.datastax.com/community/',
        distribution: 'stable',
        components: %w[main],
        key: 'https://debian.datastax.com/debian/repo_key'
      )
    end
  end
end
