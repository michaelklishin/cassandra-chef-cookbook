require 'spec_helper'

describe 'cassandra-dse::systemd' do
  context 'Centos 7.0' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['use_systemd'] = true
        node.override['cassandra']['notify_restart'] = true
        node.set['systemd']['units_dir'] = '/etc/systemd/system'
      end.converge('cassandra-dse::config', described_recipe)
    end

    it 'declares the daemon-reload resource' do
      resource = chef_run.execute('daemon-reload')
      expect(resource).to do_nothing
    end

    it 'creates the systemd unit file' do
      expect(chef_run).to create_template('/etc/systemd/system/cassandra.service').with(
        source: 'cassandra.service.erb',
        owner: 'cassandra',
        group: 'cassandra',
        mode: '0644'
      )
      template = chef_run.template('/etc/systemd/system/cassandra.service')
      expect(template).to notify('execute[daemon-reload]').to(:run).immediately
      expect(template).to notify('service[cassandra]').to(:enable).delayed
      expect(template).to notify('service[cassandra]').to(:restart).delayed
    end
  end
end
