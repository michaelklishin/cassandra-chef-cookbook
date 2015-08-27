require 'spec_helper'

describe 'cassandra-dse::default' do
  shared_examples_for 'cassandra' do
    context 'all_platforms' do
      it 'enables cassandra service' do
        expect(chef_run).to enable_service('cassandra')
        expect(chef_run).to start_service('cassandra')
      end

      it 'creates the cassandra user, group, home directory' do
        expect(chef_run).to create_user('cassandra')
        expect(chef_run).to create_group('cassandra').with(members: ['cassandra'])
        %w(/usr/share/cassandra /usr/share/cassandra/bin /var/log/cassandra /var/lib/cassandra /usr/share/cassandra/lib ).each do |d|
          expect(chef_run).to create_directory(d).with(
            owner: 'cassandra',
            group: 'cassandra'
          )
        end # %w()
      end # it
    end
  end


  context 'Centos 6.4 - yum - dsc20' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'test'
        node.set['cassandra']['version'] = '2.0.11'
        node.set['cassandra']['package_name'] = 'dsc20'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra dsc20 2.0.11-1' do
      expect(chef_run).to install_yum_package('dsc20').with(version: '2.0.11-1')
    end

    it 'Creates /usr/share/java dir' do
      expect(chef_run).to create_directory('/usr/share/java')
    end

    it 'Creates symlink between /usr/share/cassandra/lib/jna.jar and /usr/share/java/jna.jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jna.jar').with(to: '/usr/share/java/jna.jar')
    end

    it 'creates /etc/cassandra/conf/log4j-server.properties' do
      expect(chef_run).to create_template('/etc/cassandra/conf/log4j-server.properties').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/conf/cassandra.yaml' do
      expect(chef_run).to create_template('/etc/cassandra/conf/cassandra.yaml').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/cassandra-env.sh' do
      expect(chef_run).to create_template('/etc/cassandra/conf/cassandra-env.sh').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end
  end


  context 'Centos 6.4 - yum - dsc21' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|

        node.set['cassandra']['config']['cluster_name'] = 'test'
        node.set['cassandra']['version'] = '2.1.7'
        node.set['cassandra']['package_name'] = 'dsc21'

      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra dsc21 2.1.7-1' do
      expect(chef_run).to install_yum_package('dsc21').with(version: '2.1.7-1')
    end

    it 'Creates /usr/share/java dir' do
      expect(chef_run).to create_directory('/usr/share/java')
    end

    it 'Does NOT Create symlink between /usr/share/cassandra/lib/jna.jar and /usr/share/java/jna.jar' do
      expect(chef_run).to_not create_link('/usr/share/cassandra/lib/jna.jar').with(to: '/usr/share/java/jna.jar')
    end

    it 'creates /etc/cassandra/conf/logback.xml' do
      expect(chef_run).to create_template('/etc/cassandra/conf/logback.xml').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/conf/logback-tools.xml' do
      expect(chef_run).to create_template('/etc/cassandra/conf/logback-tools.xml').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/conf/cassandra.yaml' do
      expect(chef_run).to create_template('/etc/cassandra/conf/cassandra.yaml').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/cassandra-env.sh' do
      expect(chef_run).to create_template('/etc/cassandra/conf/cassandra-env.sh').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end
  end


  context 'Ubuntu 12.04 - apt - cassandra 2.0.11' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'test'
        node.set['cassandra']['version'] = '2.0.11'
        node.set['cassandra']['package_name'] = 'dsc20'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra 2.0.11' do
      expect(chef_run).to install_package('dsc20')
    end

    it 'installs cassandra' do
      expect(chef_run).to install_package('python-cql')
    end

    it 'Creates /usr/share/java dir' do
      expect(chef_run).to create_directory('/usr/share/java')
    end

    it 'Creates symlink between /usr/share/cassandra/lib/jna.jar and /usr/share/java/jna.jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jna.jar').with(to: '/usr/share/java/jna.jar')
    end

    it 'creates /etc/cassandra/log4j-server.properties' do
      expect(chef_run).to create_template('/etc/cassandra/log4j-server.properties').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/cassandra.yaml' do
      expect(chef_run).to create_template('/etc/cassandra/cassandra.yaml').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

    it 'creates /etc/cassandra/cassandra-env.sh' do
      expect(chef_run).to create_template('/etc/cassandra/cassandra-env.sh').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end
  end
end
