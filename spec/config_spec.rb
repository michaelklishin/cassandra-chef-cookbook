require 'spec_helper'

describe 'cassandra-dse::config' do
  context 'all config options enalbed on rhel platform_family' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        # turn on all only_if attributes
        node.default['cassandra']['commitlog_dir'] = '/var/lib/cassandra/commitlog'
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['metrics_reporter']['enabled'] = true
        node.default['cassandra']['rackdc'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.default['cassandra']['saved_caches_dir'] = '/var/lib/cassandra/saved_caches'
        node.default['cassandra']['snitch_conf'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.override['cassandra']['setup_jamm'] = true
        node.override['cassandra']['setup_priam'] = true
        node.override['cassandra']['setup_jna'] = true
        node.override['cassandra']['notify_restart'] = true
        node.override['cassandra']['jvm']['g1'] = true

        # provide a testable hash to verify template generation
        node.override['cassandra']['metrics_reporter']['config'] = { 'test1' => 'value1', 'test2' => %w[value2 value3] }
      end.converge(described_recipe)
    end

    it 'installs the jna.jar file' do # ~FC005
      expect(chef_run).to create_remote_file('/usr/share/java/jna.jar').with(
        source: 'https://github.com/twall/jna/raw/4.0/dist/jna.jar',
        checksum: 'dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19'
      )
    end

    it 'sets up a link for the jna jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jna.jar').with(
        to: '/usr/share/java/jna.jar'
      )
    end

    it 'downloads the /usr/share/java/jamm-0.3.1.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/jamm-0.3.1.jar').with(
        source: 'https://repo1.maven.org/maven2/com/github/jbellis/jamm/0.3.1/jamm-0.3.1.jar',
        checksum: 'b599dc7a58b305d697bbb3d897c91f342bbddefeaaf10a3fa156c93efca397ef'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jamm-0.3.1.jar').with(
        to: '/usr/share/java/jamm-0.3.1.jar'
      )
    end

    it 'downloads the priam-cass-extensions-2.2.0.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/priam-cass-extensions-2.2.0.jar').with(
        source: 'http://search.maven.org/remotecontent?filepath=com/netflix/priam/priam-cass-extensions/2.2.0/priam-cass-extensions-2.2.0.jar',
        checksum: '9fde9a40dc5c538adee54f40fa9027cf3ebb7fd42e3592b3e6fdfe3f7aff81e1'
      )
    end

    it 'sets up a link for the priam-cass extensions jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/priam-cass-extensions-2.2.0.jar').with(
        to: '/usr/share/java/priam-cass-extensions-2.2.0.jar'
      )
    end

    it 'creates the metrics reporter jar file' do
      expect(chef_run).to create_remote_file('/usr/share/java/metrics-graphite-2.2.0.jar').with(
        source: 'http://search.maven.org/remotecontent?filepath=com/yammer/metrics/metrics-graphite/2.2.0/metrics-graphite-2.2.0.jar',
        checksum: '6b4042aabf532229f8678b8dcd34e2215d94a683270898c162175b1b13d87de4'
      )
    end

    it 'links /usr/share/cassandra/lib/metrics-graphite.jar to /usr/share/java/metrics-graphite-2.2.0.jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/metrics-graphite.jar').with(
        to: '/usr/share/java/metrics-graphite-2.2.0.jar'
      )
    end

    %w[cassandra.yaml cassandra-env.sh cassandra-topology.properties jvm.options
       cassandra-metrics.yaml cassandra-rackdc.properties logback.xml logback-tools.xml].each do |conffile|
      let(:template) { chef_run.template("/etc/cassandra/conf/#{conffile}") }
      it "creates the /etc/cassandra/conf/#{conffile} configuration file" do # ~FC005
        expect(chef_run).to create_template("/etc/cassandra/conf/#{conffile}").with(
          source: "#{conffile}.erb",
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
      end

      it "renders the /etc/cassandra/conf/#{conffile} with content from ./spec/rendered_templates/#{conffile}" do
        content = File.read("./spec/rendered_templates/#{conffile}")
        expect(chef_run).to render_file("/etc/cassandra/conf/#{conffile}")
          .with_content(content)
      end

      it "restarts the cassandra service if there is a chage to #{conffile}" do
        expect(template).to notify('service[cassandra]').to(:restart)
      end
    end
  end

  context 'all config options enalbed on debian platform_family' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        # turn on all only_if attributes
        node.default['cassandra']['commitlog_dir'] = '/var/lib/cassandra/commitlog'
        node.override['cassandra']['conf_dir'] = '/etc/cassandra'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['metrics_reporter']['enabled'] = true
        node.default['cassandra']['rackdc'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.default['cassandra']['saved_caches_dir'] = '/var/lib/cassandra/saved_caches'
        node.default['cassandra']['snitch_conf'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.override['cassandra']['setup_priam'] = true
        node.override['cassandra']['setup_jamm'] = true
        node.override['cassandra']['setup_jna'] = true
        node.override['cassandra']['notify_restart'] = true
        node.override['cassandra']['jvm']['g1'] = true

        # provide a testable hash to verify template generation
        node.override['cassandra']['metrics_reporter']['config'] = { 'test1' => 'value1', 'test2' => %w[value2 value3] }
      end.converge(described_recipe)
    end

    %w[cassandra.yaml cassandra-env.sh cassandra-topology.properties jvm.options
       cassandra-metrics.yaml cassandra-rackdc.properties logback.xml logback-tools.xml].each do |conffile|
      let(:template) { chef_run.template("/etc/cassandra/#{conffile}") }

      it "creates the /etc/cassandra/#{conffile} configuration file" do
        expect(chef_run).to create_template("/etc/cassandra/#{conffile}").with(
          source: "#{conffile}.erb",
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
      end

      it "renders the /etc/cassandra/#{conffile} with content from ./spec/rendered_templates/#{conffile}" do
        content = File.read("./spec/rendered_templates/#{conffile}")
        expect(chef_run).to render_file("/etc/cassandra/#{conffile}").with_content(content)
      end

      it "restarts the cassandra service if there is a chage to #{conffile}" do
        expect(template).to notify('service[cassandra]').to(:restart)
      end
    end
  end

  context 'default' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['metrics_reporter']['enabled'] = false
      end.converge(described_recipe)
    end

    it 'does not create the cassandra-metrics.yaml file in /etc/cassandra/' do
      expect(chef_run).to_not create_template('/etc/cassandra/conf/cassandra-metrics.yaml')
    end

    it 'does not create the cassandra-rackdc.properties file in /etc/cassandra/conf' do
      expect(chef_run).to_not create_template('/etc/cassandra/conf/cassandra-rackdc.properties')
    end

    it 'does create /usr/share/java directory' do
      expect(chef_run).to create_directory('/usr/share/java').with(
        owner: 'root',
        group: 'root',
        mode: '00755'
      )
    end

    it 'creates the log file /var/log/cassandra/system.log and sets the permissions' do
      expect(chef_run).to create_file('/var/log/cassandra/system.log').with(
        owner: 'cassandra',
        group: 'cassandra',
        mode: '0644'
      )
    end

    it 'creates the log file /var/log/cassandra/boot.log and sets the permissions' do
      expect(chef_run).to create_file('/var/log/cassandra/boot.log').with(
        owner: 'cassandra',
        group: 'cassandra',
        mode: '0644'
      )
    end

    it 'executes the "smash < 2.0-attributes" ruby block' do
      expect(chef_run).to run_ruby_block('smash < 2.0-attributes')
    end

    it 'does not create the jmxremote.access file' do
      expect(chef_run).to_not create_template('/etc/cassandra/conf/jmxremote.access')
    end

    it 'does not create the jmxremote.password file' do
      expect(chef_run).to_not create_template('/etc/cassandra/conf/jmxremote.password')
    end

    it 'does enable the cassandra service' do
      expect(chef_run).to enable_service('cassandra').with(
        service_name: 'cassandra'
      )
    end

    it 'does start the cassandra service' do
      expect(chef_run).to start_service('cassandra').with(
        service_name: 'cassandra'
      )
    end
  end

  context 'skip jna' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.default['cassandra']['metrics_reporter']['enabled'] = false
        node.override['cassandra']['skip_jna'] = true
      end.converge(described_recipe)
    end

    it 'deletes the jna.jar file' do
      expect(chef_run).to delete_file('/usr/share/cassandra/lib/jna.jar')
    end
  end

  context 'turn on jmx authentication' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.default['cassandra']['local_jmx'] = false
        node.override['cassandra']['jmx_remote_authenticate'] = true
        node.override['cassandra']['jmx_access_path'] = '/etc/cassandra/jmxremote.access'
        node.override['cassandra']['jmx_password_path'] = '/etc/cassandra/jmxremote.password'
        node.default['cassandra']['jmx']['password'] = 'cassandra'
      end.converge(described_recipe)
    end

    it 'adds jmx authentication jvm argument to cassandra-env' do
      expect(chef_run).to render_file('/etc/cassandra/conf/cassandra-env.sh')
        .with_content('-Dcom.sun.management.jmxremote.authenticate=true')
    end

    it 'adds jmxremote credential file paths to cassandra-env' do
      expect(chef_run).to render_file('/etc/cassandra/conf/cassandra-env.sh')
        .with_content('JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.password.file=$CASSANDRA_CONF/jmxremote.password"')
    end

    it 'adds jmxremote credential file paths to cassandra-env' do
      expect(chef_run).to render_file('/etc/cassandra/conf/cassandra-env.sh')
        .with_content('JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.access.file=$CASSANDRA_CONF/jmxremote.access"')
    end

    it 'creates the jmxremote.access file' do
      expect(chef_run).to create_template('/etc/cassandra/jmxremote.access').with(
        owner: 'cassandra',
        group: 'cassandra',
        mode: '0400'
      )
    end

    it 'grants access to cassandra user' do
      expect(chef_run).to render_file('/etc/cassandra/jmxremote.access')
        .with_content('cassandra     readwrite')
    end

    it 'stores the cassandra user\'s password' do
      expect(chef_run).to render_file('/etc/cassandra/jmxremote.password')
        .with_content('cassandra cassandra')
    end
  end

  context 'jamm and priam with cassandra version 1 or 2.0' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['version'] = '2.0.11'
        node.override['cassandra']['package_name'] = 'dsc20'
        node.override['cassandra']['setup_jamm'] = true
        node.override['cassandra']['setup_priam'] = true
      end.converge(described_recipe)
    end

    it 'downloads the /usr/share/java/jamm-0.2.5.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/jamm-0.2.5.jar').with(
        source: 'https://repo1.maven.org/maven2/com/github/stephenc/jamm/0.2.5/jamm-0.2.5.jar',
        checksum: 'e3dd1200c691f8950f51a50424dd133fb834ab2ce9920b05aa98024550601cc5'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jamm-0.2.5.jar').with(
        to: '/usr/share/java/jamm-0.2.5.jar'
      )
    end

    it 'downloads the /usr/share/java/priam-cass-extensions-2.0.11.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/priam-cass-extensions-2.0.11.jar').with(
        source: 'http://search.maven.org/remotecontent?filepath=com/netflix/priam/priam-cass-extensions/2.0.11/priam-cass-extensions-2.0.11.jar',
        checksum: '9fde9a40dc5c538adee54f40fa9027cf3ebb7fd42e3592b3e6fdfe3f7aff81e1'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/priam-cass-extensions-2.0.11.jar').with(
        to: '/usr/share/java/priam-cass-extensions-2.0.11.jar'
      )
    end
  end

  context 'jamm and priam with cassandra version 2.1' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['version'] = '2.1.7'
        node.override['cassandra']['package_name'] = 'dsc21'
        node.override['cassandra']['setup_jamm'] = true
        node.override['cassandra']['setup_priam'] = true
      end.converge(described_recipe)
    end

    it 'downloads the /usr/share/java/jamm-0.3.1.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/jamm-0.3.1.jar').with(
        source: 'https://repo1.maven.org/maven2/com/github/jbellis/jamm/0.3.1/jamm-0.3.1.jar',
        checksum: 'b599dc7a58b305d697bbb3d897c91f342bbddefeaaf10a3fa156c93efca397ef'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/jamm-0.3.1.jar').with(
        to: '/usr/share/java/jamm-0.3.1.jar'
      )
    end

    it 'downloads the /usr/share/java/priam-cass-extensions-2.1.7.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/priam-cass-extensions-2.1.7.jar').with(
        source: 'http://search.maven.org/remotecontent?filepath=com/netflix/priam/priam-cass-extensions/2.1.7/priam-cass-extensions-2.1.7.jar',
        checksum: '9fde9a40dc5c538adee54f40fa9027cf3ebb7fd42e3592b3e6fdfe3f7aff81e1'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/priam-cass-extensions-2.1.7.jar').with(
        to: '/usr/share/java/priam-cass-extensions-2.1.7.jar'
      )
    end
  end

  context 'priam with cassandra version 2.2.1' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['version'] = '2.2.1'
        node.override['cassandra']['package_name'] = 'dsc21'
        node.override['cassandra']['setup_priam'] = true
      end.converge(described_recipe)
    end

    it 'downloads the /usr/share/java/priam-cass-extensions-2.2.1.jar jar' do
      expect(chef_run).to create_remote_file('/usr/share/java/priam-cass-extensions-2.2.1.jar').with(
        source: 'http://search.maven.org/remotecontent?filepath=com/netflix/priam/priam-cass-extensions/2.2.1/priam-cass-extensions-2.2.1.jar',
        checksum: '9fde9a40dc5c538adee54f40fa9027cf3ebb7fd42e3592b3e6fdfe3f7aff81e1'
      )
    end

    it 'sets up a link for the jamm jar' do
      expect(chef_run).to create_link('/usr/share/cassandra/lib/priam-cass-extensions-2.2.1.jar').with(
        to: '/usr/share/java/priam-cass-extensions-2.2.1.jar'
      )
    end
  end

  context 'config files with cassandra version 1 or 2.0' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['cassandra']['conf_dir'] = '/etc/cassandra/conf'
        node.override['cassandra']['config']['cluster_name'] = 'chefspec'
        node.override['cassandra']['lib_dir'] = '/usr/share/cassandra/lib'
        node.override['cassandra']['metrics_reporter']['enabled'] = true
        node.override['cassandra']['notify_restart'] = true
        node.override['cassandra']['package_name'] = 'dsc20'
        node.default['cassandra']['rackdc'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.default['cassandra']['snitch_conf'] = { 'dc' => 'testdc', 'rack' => 'testrack' }
        node.override['cassandra']['version'] = '2.0.11'
      end.converge(described_recipe)
    end

    it 'executes the "smash >= 2.1-attributes" ruby block' do
      expect(chef_run).to run_ruby_block('smash >= 2.1-attributes')
    end

    %w[cassandra.yaml cassandra-env.sh cassandra-topology.properties jvm.options
       cassandra-metrics.yaml cassandra-rackdc.properties log4j-server.properties].each do |conffile|
      let(:template) { chef_run.template("/etc/cassandra/conf/#{conffile}") }
      it "creates the /etc/cassandra/conf/#{conffile} configuration file" do # ~FC005
        expect(chef_run).to create_template("/etc/cassandra/conf/#{conffile}").with(
          source: "#{conffile}.erb",
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        )
      end

      it "restarts the cassandra service if there is a chage to #{conffile}" do
        expect(template).to notify('service[cassandra]').to(:restart)
      end
    end
  end
end
