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
        %w[
          /var/log/cassandra
          /var/lib/cassandra
          /var/lib/cassandra/data
          /var/run/cassandra
          /usr/share/cassandra
          /usr/share/cassandra/lib
        ].each do |d|
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

  context 'Centos 7.0 - yum - dsc20' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.0.11'
        node.override['cassandra']['package_name'] = 'dsc20'
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

    # only create link if there is a different conf dir
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

  context 'Centos 7.0 - yum - dsc21' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.1.7'
        node.override['cassandra']['package_name'] = 'dsc21'
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

  context 'Centos 7.0 - yum - dsc22' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.2.1'
        node.override['cassandra']['package_name'] = 'dsc22'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra dsc21 2.2.1-1' do
      expect(chef_run).to install_yum_package('dsc22').with(version: '2.2.1-1')
    end

    it 'does not run "set_jvm_search_dirs_on_java_8" ruby block' do
      expect(chef_run).to_not run_ruby_block('set_jvm_search_dirs_on_java_8')
    end
  end

  context 'Centos 7.0 - yum - dsc30' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '3.0.9'
        node.override['cassandra']['package_name'] = 'dsc30'
        node.override['java']['jdk_version'] = 8
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra dsc30 3.0.9-1' do
      expect(chef_run).to install_yum_package('dsc30').with(version: '3.0.9-1')
    end

    it 'not run "set_jvm_search_dirs_on_java_8" ruby block without notification' do
      expect(chef_run).to_not run_ruby_block('set_jvm_search_dirs_on_java_8')
    end

    it 'does not download the priam-cass-extensions-3.0.9.jar jar' do
      expect(chef_run).to_not create_remote_file('/usr/share/java/priam-cass-extensions-3.0.9.jar')
    end

    it 'does not set up a link for the priam-cass extensions jar' do
      expect(chef_run).to_not create_link('/usr/share/cassandra/lib/priam-cass-extensions-3.0.9.jar')
    end
  end

  context 'Centos 7.0 - yum - dsc22 - custom conf_dir' do
    before do
      original_file_exist = ::File.method(:exist?)
      allow(::File).to receive(:exist?) do |arg|
        if arg == '/etc/mycassandra/conf'
          false
        else
          original_file_exist.call(arg)
        end
      end
    end

    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.2.1'
        node.override['cassandra']['package_name'] = 'dsc22'
        node.override['cassandra']['conf_dir'] = '/etc/mycassandra/conf'
      end.converge(described_recipe)
    end

    it 'creates the directory /etc/cassandra' do
      expect(chef_run).to create_directory('/etc/mycassandra').with(
        owner: 'cassandra',
        group: 'cassandra',
        recursive: true,
        mode: '0755'
      )
    end

    it 'creates the directory /etc/mycassandra/conf' do
      expect(chef_run).to create_directory('/etc/mycassandra/conf').with(
        owner: 'cassandra',
        group: 'cassandra',
        recursive: true,
        mode: '0755'
      )
    end

    it 'Creates a symlink from conf_dir to /etc/cassandra/conf' do
      link = chef_run.link('/etc/mycassandra/conf')
      expect(link).to link_to('/etc/cassandra/conf')
    end

    %w[
      cassandra.yaml
      cassandra-env.sh
      jvm.options
      logback.xml
      logback-tools.xml
    ].each do |conffile|
      it "creates the /etc/mycassandra/conf/#{conffile} configuration file" do
        expect(chef_run).to create_template("/etc/mycassandra/conf/#{conffile}").with(
          source: "#{conffile}.erb",
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
      end
    end

    %w[
      cassandra-topology.properties
      cassandra-metrics.yaml
      cassandra-rackdc.properties
      jmxremote.access
      jmxremote.password
    ].each do |conffile|
      it "does not create the /etc/mycassandra/conf/#{conffile} configuration file" do
        expect(chef_run).to_not create_template("/etc/mycassandra/conf/#{conffile}")
      end
    end
  end

  context 'Centos 7.0 - yum - dsc22 - custom conf dir already exists' do
    before do
      original_file_exist = ::File.method(:exist?)
      allow(::File).to receive(:exist?) do |arg|
        if arg == '/etc/mycassandra/conf'
          true
        else
          original_file_exist.call(arg)
        end
      end
    end

    # Can't use cached when using rspec-mock
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.2.1'
        node.override['cassandra']['package_name'] = 'dsc22'
        node.override['cassandra']['conf_dir'] = '/etc/mycassandra/conf'
      end.converge(described_recipe)
    end

    it 'creates the directory /etc/mycassandra/conf' do
      expect(chef_run).to create_directory('/etc/mycassandra/conf').with(
        owner: 'cassandra',
        group: 'cassandra',
        recursive: true,
        mode: '0755'
      )
    end

    it 'does not create a symlink from conf_dir to /etc/mycassandra/conf' do
      expect(chef_run).to_not create_link('/etc/mycassandra/conf')
    end
  end

  context 'Ubuntu 14.04 - apt - cassandra 2.0.11' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.0.11'
        node.override['cassandra']['package_name'] = 'dsc20'
      end.converge(described_recipe)
    end

    include_examples 'cassandra'

    it 'installs cassandra 2.0.11' do
      expect(chef_run).to install_package('dsc20')
    end

    it 'installs python-cql' do
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

  context 'Ubuntu 16.04 - apt - dsc22' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        node.override['cassandra']['config']['cluster_name'] = 'test'
        node.override['cassandra']['version'] = '2.2.1'
        node.override['cassandra']['package_name'] = 'dsc22'
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

    it 'does not install python-cql' do
      expect(chef_run).to_not install_package('python-cql')
    end
  end
end
