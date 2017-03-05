#
# Cookbook Name:: cassandra-dse
# Recipe:: config
#
# Copyright 2015, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# TODO: update referenced attributes for config
node.default['cassandra']['config']['data_file_directories'] = node['cassandra']['data_dir']
node.default['cassandra']['config']['saved_caches_directory'] = node['cassandra']['saved_caches_dir']
node.default['cassandra']['config']['commitlog_directory'] = node['cassandra']['commitlog_dir']

node.default['cassandra']['seeds'] = discover_seed_nodes

node.default['cassandra']['config']['seed_provider'] = [{
  'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
  'parameters' => [
    'seeds' => discover_seed_nodes
  ]
}]

# touch log files
[
  ::File.join(node['cassandra']['log_dir'], 'system.log'),
  ::File.join(node['cassandra']['log_dir'], 'boot.log')
].each do |f|
  file f do
    owner node['cassandra']['user']
    group node['cassandra']['group']
    mode '0644'
  end
end

# create if missing
directory '/usr/share/java' do
  owner 'root'
  group 'root'
  mode '00755'
end

if node['cassandra'].attribute?('tmp_dir')
  directory node['cassandra']['tmp_dir'] do
    action :create
    recursive true
    owner node['cassandra']['user']
    group node['cassandra']['group']
    mode '0755'
  end
end

# delete properties on the basis of C* version
# C* <= 2.0
if node['cassandra']['version'][0..2] <= '2.0'
  ruby_block 'smash >= 2.1-attributes' do
    block do
      node.rm('cassandra', 'config', 'broadcast_rpc_address')
      node.rm('cassandra', 'config', 'tombstone_failure_threshold')
      node.rm('cassandra', 'config', 'tombstone_warn_threshold')
      node.rm('cassandra', 'config', 'sstable_preemptive_open_interval_in_mb')
      node.rm('cassandra', 'config', 'memtable_allocation_type')
      node.rm('cassandra', 'config', 'index_summary_capacity_in_mb')
      node.rm('cassandra', 'config', 'index_summary_resize_interval_in_minutes')
      node.rm('cassandra', 'config', 'concurrent_counter_writes')
      node.rm('cassandra', 'config', 'counter_cache_save_period')
      node.rm('cassandra', 'config', 'counter_cache_size_in_mb')
      node.rm('cassandra', 'config', 'counter_write_request_timeout_in_ms')
      node.rm('cassandra', 'config', 'commit_failure_policy')
      node.rm('cassandra', 'config', 'cas_contention_timeout_in_ms')
      node.rm('cassandra', 'config', 'batch_size_warn_threshold_in_kb')
      node.rm('cassandra', 'config', 'batchlog_replay_throttle_in_kb')
      node.rm('cassandra', 'config', 'permissions_validity_in_ms')
    end
  end
end

# C* 2.1.0
if node['cassandra']['version'][0..2] >= '2.1'
  ruby_block 'smash < 2.0-attributes' do
    block do
      node.rm('cassandra', 'config', 'memtable_flush_queue_size')
      node.rm('cassandra', 'config', 'in_memory_compaction_limit_in_mb')
      node.rm('cassandra', 'config', 'multithreaded_compaction')
      node.rm('cassandra', 'config', 'compaction_preheat_key_cache')
      node.rm('cassandra', 'config', 'native_transport_min_threads')
    end
  end
end

# C* 3.x
if node['cassandra']['version'][0..2] >= '3.0'
  node.default['cassandra']['config']['hints_directory'] = \
    ::File.join(node['cassandra']['root_dir'], 'hints')
end

# configuration files
template ::File.join(node['cassandra']['conf_dir'], 'cassandra.yaml') do
  cookbook node['cassandra']['templates_cookbook']
  source 'cassandra.yaml.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end

template ::File.join(node['cassandra']['conf_dir'], 'jvm.options') do
  cookbook node['cassandra']['templates_cookbook']
  source 'jvm.options.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end

template ::File.join(node['cassandra']['conf_dir'], 'cassandra-env.sh') do
  cookbook node['cassandra']['templates_cookbook']
  source 'cassandra-env.sh.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end

node['cassandra']['log_config_files'].each do |f|
  template ::File.join(node['cassandra']['conf_dir'], f) do
    cookbook node['cassandra']['templates_cookbook']
    source "#{f}.erb"
    owner node['cassandra']['user']
    group node['cassandra']['group']
    mode '0644'
    notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  end
end

template ::File.join(node['cassandra']['conf_dir'], 'cassandra-rackdc.properties') do
  source 'cassandra-rackdc.properties.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  variables(rackdc: node['cassandra']['rackdc'])
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra'].attribute?('rackdc') }
end

# diff
template ::File.join(node['cassandra']['conf_dir'], 'cassandra-topology.properties') do
  cookbook node['cassandra']['templates_cookbook']
  source 'cassandra-topology.properties.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  variables(snitch: node['cassandra']['snitch_conf'])
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra'].attribute?('snitch_conf') }
end

# setup metrics reporter

remote_file "/usr/share/java/#{node['cassandra']['metrics_reporter']['jar_name']}" do
  source node['cassandra']['metrics_reporter']['jar_url']
  checksum node['cassandra']['metrics_reporter']['sha256sum']
  only_if { node['cassandra']['metrics_reporter']['enabled'] }
end

link "#{node['cassandra']['lib_dir']}/#{node['cassandra']['metrics_reporter']['name']}.jar" do
  to "/usr/share/java/#{node['cassandra']['metrics_reporter']['jar_name']}"
  owner node['cassandra']['user']
  group node['cassandra']['group']
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['metrics_reporter']['enabled'] }
end

template ::File.join(node['cassandra']['conf_dir'], 'cassandra-metrics.yaml') do
  cookbook node['cassandra']['templates_cookbook']
  source 'cassandra-metrics.yaml.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  variables(yaml_config: hash_to_yaml_string(node['cassandra']['metrics_reporter']['config']))
  only_if { node['cassandra']['metrics_reporter']['enabled'] }
end

# set up jamm
remote_file "/usr/share/java/#{node['cassandra']['jamm']['jar_name']}" do
  source "#{node['cassandra']['jamm']['base_url']}/#{node['cassandra']['jamm']['jar_name']}"
  mode '0644'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  checksum node['cassandra']['jamm']['sha256sum']
  only_if { node['cassandra']['setup_jamm'] }
end

link "#{node['cassandra']['lib_dir']}/#{node['cassandra']['jamm']['jar_name']}" do
  owner node['cassandra']['user']
  group node['cassandra']['group']
  to "/usr/share/java/#{node['cassandra']['jamm']['jar_name']}"
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['setup_jamm'] }
end

# set up priam
remote_file "/usr/share/java/#{node['cassandra']['priam']['jar_name']}" do
  source "#{node['cassandra']['priam']['base_url']}/#{node['cassandra']['priam']['jar_name']}"
  mode   '0644'
  checksum node['cassandra']['priam']['sha256sum']
  only_if { node['cassandra']['setup_priam'] }
end

link "#{node['cassandra']['lib_dir']}/#{node['cassandra']['priam']['jar_name']}" do
  to "/usr/share/java/#{node['cassandra']['priam']['jar_name']}"
  owner node['cassandra']['user']
  group node['cassandra']['group']
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['setup_priam'] }
end

# set up jna
remote_file '/usr/share/java/jna.jar' do
  source "#{node['cassandra']['jna']['base_url']}/#{node['cassandra']['jna']['jar_name']}"
  mode   '0644'
  checksum node['cassandra']['jna']['sha256sum']
  only_if { node['cassandra']['setup_jna'] }
end

link "#{node['cassandra']['lib_dir']}/jna.jar" do
  to '/usr/share/java/jna.jar'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['setup_jna'] }
end

file "#{node['cassandra']['lib_dir']}/jna.jar" do
  action :delete
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['skip_jna'] }
end

# set up JMX authentication
node.default['cassandra']['jmx_access_path'] = \
  ::File.join(node['cassandra']['conf_dir'], 'jmxremote.access')
node.default['cassandra']['jmx_password_path'] = \
  ::File.join(node['cassandra']['conf_dir'], 'jmxremote.password')

template node['cassandra']['jmx_access_path'] do
  cookbook node['cassandra']['templates_cookbook']
  source 'jmxremote.access.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0400'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['jmx_remote_authenticate'] }
end

template node['cassandra']['jmx_password_path'] do
  cookbook node['cassandra']['templates_cookbook']
  source 'jmxremote.password.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0400'
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
  only_if { node['cassandra']['jmx_remote_authenticate'] }
end

service 'cassandra' do
  supports restart: true, status: true
  service_name node['cassandra']['service_name']
  action node['cassandra']['service_action']
  only_if { node['cassandra']['use_initd'] || node['cassandra']['use_systemd'] }
end
