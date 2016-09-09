require 'spec_helper'

describe 'cassandra-dse::default' do
  shared_examples_for 'cassandra' do
    context 'all_platforms' do
      it 'enables cassandra service' do
        expect(chef_run).to enable_service('cassandra')
        expect(chef_run).to start_service('cassandra')
      end

      it 'creates the cassandra user' do
        expect(chef_run).to create_user('cassandra').with(
          comment: 'Cassandra Server user',
          gid: 'cassandra',
          home: nil,
          system: true,
          shell: '/bin/bash'
        )
      end

      it 'creates the cassandra group' do
        expect(chef_run).to create_group('cassandra')
      end

      it 'explicity adds the cassandra user to the cassandra group' do
        expect(chef_run).to modify_group('explicity add cassandra to cassandra group').with(
          members: ['cassandra'],
          group_name: 'cassandra',
          append: true
        )
      end

      it 'creates the cassandra home directory' do
        %w(/usr/share/cassandra /var/log/cassandra /var/lib/cassandra /usr/share/cassandra/lib).each do |d|
          expect(chef_run).to create_directory(d).with(
            owner: 'cassandra',
            group: 'cassandra'
          )
        end
      end

      it 'creates the directory /etc/cassandra' do
        expect(chef_run).to create_directory('/etc/cassandra').with(
          owner: 'cassandra',
          group: 'cassandra',
          recursive: true,
          mode: '0755'
        )
      end
    end
  end

  context 'Centos 6.4 - yum - dsc20' do
    cached(:chef_run) do
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

    it 'creates and sets permissions of /etc/cassandra/conf' do
      expect(chef_run).to create_directory('/etc/cassandra/conf').with(
        owner: 'cassandra',
        group: 'cassandra',
        recursive: true,
        mode: '0755'
      )
    end

    # only create link if there is a diffrent conf dir
    it 'Creates symlink between /etc/cassandra/conf and ' do
      expect(chef_run).to_not create_link('/etc/cassandra/conf')
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

    it 'creates /etc/cassandra/jvm.options' do
      expect(chef_run).to create_template('/etc/cassandra/conf/jvm.options').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end

  end

  context 'Centos 6.4 - yum - dsc21' do
    cached(:chef_run) do
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

    it 'creates /etc/cassandra/jvm.options' do
      expect(chef_run).to create_template('/etc/cassandra/conf/jvm.options').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end
  end

  context 'Centos 6.4 - yum - dsc22' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'test'
        node.set['cassandra']['version'] = '2.2.1'
        node.set['cassandra']['package_name'] = 'dsc22'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra dsc21 2.2.1-1' do
      expect(chef_run).to install_yum_package('dsc22').with(version: '2.2.1-1')
    end
  end

  context 'Ubuntu 12.04 - apt - cassandra 2.0.11' do
    cached(:chef_run) do
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

    it 'uses apt to pin the priority of dsc22 to version xxx' do
      expect(chef_run).to add_apt_preference('dsc20').with(
        pin: 'version 2.0.11-1',
        pin_priority: '700'
      )
    end

    it 'uses apt to pin the priority of dsc22 to version xxx' do
      expect(chef_run).to add_apt_preference('cassandra').with(
        pin: 'version 2.0.11',
        pin_priority: '700'
      )
    end

    it 'defines a ruby block sleep resource' do
      expect(chef_run).to_not run_ruby_block('sleep30s')
    end

    it 'defines a ruby block set_fd_limit resource' do
      expect(chef_run).to_not run_ruby_block('set_fd_limit')
    end

    it 'defines a "set_cluster_name" resource to be called on cluster name update' do
      expect(chef_run).to_not run_execute('set_cluster_name')
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

    it 'creates /etc/cassandra/jvm.options' do
      expect(chef_run).to create_template('/etc/cassandra/jvm.options').with(
        owner: 'cassandra',
        group: 'cassandra'
      )
    end
  end

  context 'Ubuntu 12.04 - apt - dsc22' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'test'
        node.set['cassandra']['version'] = '2.2.1'
        node.set['cassandra']['package_name'] = 'dsc22'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'uses apt to pin the priority of dsc22 to version xxx' do
      expect(chef_run).to add_apt_preference('dsc22').with(
        pin: 'version 2.2.1-1',
        pin_priority: '700'
      )
    end

    it 'installs cassandra 2.2.1' do
      expect(chef_run).to install_package('cassandra').with(version: '2.2.1')
    end

    it 'installs cassandra dsc22 2.2.1-1' do
      expect(chef_run).to install_package('dsc22').with(version: '2.2.1-1')
    end
  end
end
