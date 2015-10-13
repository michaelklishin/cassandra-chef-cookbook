require 'spec_helper'

describe 'cassandra-dse' do
  context 'metrics enabled' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'chefspec'
        node.set['cassandra']['metrics_reporter']['enabled'] = true
        # provide a testable hash to verify template generation
        node.set['cassandra']['metrics_reporter']['config'] = {'test1' => 'value1', 'test2' => ['value2', 'value3']}
      end.converge(described_recipe)
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

    it 'creates the cassandra-metrics.yaml file in /etc/cassandra/' do
      expect(chef_run).to create_template('/etc/cassandra/conf/cassandra-metrics.yaml').with(
        cookbook: 'cassandra-dse',
        source: 'cassandra-metrics.yaml.erb',
        owner: 'cassandra',
        group: 'cassandra',
        mode: 0644
      )
    end

    it 'renders the /etc/cassandra/conf/cassandra-metrics.yaml with content from ./spec/rendered_templates/cassandra-metrics.yaml' do
      cassandra_metrics_yaml = File.read('./spec/rendered_templates/cassandra-metrics.yaml')
      expect(chef_run).to render_file('/etc/cassandra/conf/cassandra-metrics.yaml')
        .with_content(cassandra_metrics_yaml)
    end
  end


  context 'default' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.4') do |node|
        node.set['cassandra']['config']['cluster_name'] = 'chefspec'
        node.set['cassandra']['metrics_reporter']['enabled'] = false
      end.converge(described_recipe)
    end

    it 'creates the cassandra-metrics.yaml file in /etc/cassandra/' do
      expect(chef_run).to_not create_template('/etc/cassandra/conf/cassandra-metrics.yaml')
    end

    it 'creates the cassandra-rackdc.properties file in /etc/cassandra/conf' do
      expect(chef_run).to create_template('/extc/cassandra/conf/cassandra-rackdc.properties')#.with(
        #source: 'cassandra-rackdc.properties.erb',
        #owner: 'cassandra',
        #group: 'cassandra',
        #mode: 0644
      #)
    end

    it 'renders the /etc/cassandra/conf/cassandra-rackdc.properties with content from ./spec/rendered_templates/cassandra-rackdc.properties' do
      cassandra_metrics_yaml = File.read('./spec/rendered_templates/cassandra-rackdc.properties')
      expect(chef_run).to render_file('/etc/cassandra/conf/cassandra-rackdc.properties')
        .with_content(cassandra_metrics_yaml)
    end
  end
end
