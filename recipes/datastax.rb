#
# Cookbook Name:: cassandra-dse
# Recipe:: datastax
#
# Copyright 2011-2015, Michael S Klishin & Travis CI Development Team
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

case node['cassandra']['version']
# Submit an issue if jamm version is not correct for 0.x or 1.x version
when /^0\./, /^1\./, /^2\.0/
  # < 2.1 Versions
  node.default['cassandra']['setup_jna'] = true
  node.default['cassandra']['cassandra_old_version_20'] = true
else
  # >= 2.1 Version
  node.default['cassandra']['setup_jna'] = false
  node.default['cassandra']['skip_jna'] = false
  node.default['cassandra']['setup_jamm'] = true
  node.default['cassandra']['cassandra_old_version_20'] = false
end

node.default['cassandra']['installation_dir'] = '/usr/share/cassandra'
# node['cassandra']['installation_dir subdirs
node.default['cassandra']['bin_dir'] = '/usr/bin' # package default folder for tools
node.default['cassandra']['sbin_dir'] = '/usr/sbin' # package default for daemon startup binary
node.default['cassandra']['lib_dir'] = ::File.join(node['cassandra']['installation_dir'], 'lib')

# commit log, data directory, saved caches and so on are all stored under the data root. MK.
# node['cassandra']['root_dir sub dirs
# For JBOD functionality use two attributes: node['cassandra']['jbod']['slices'] and node['cassandra']['jbod']['dir_name_prefix']
# node['cassandra']['jbod']['slices'] defines the number of jbod slices while each represents data directory
# node['cassandra']['jbod']['dir_name_prefix'] defines prefix of the data directory
# For example if you want to connect 4 EBS disks as a JBOD slices the names will be in the following format: data1,data2,data3,data4
# cassandra.yaml.erb will generate automatically entry per data_dir location

data_dir = []
if !node['cassandra']['jbod']['slices'].nil?
  node['cassandra']['jbod']['slices'].times do |slice_number|
    data_dir << ::File.join(node['cassandra']['root_dir'], "#{node['cassandra']['jbod']['dir_name_prefix']}#{slice_number}")
  end
else
  data_dir << ::File.join(node['cassandra']['root_dir'], 'data')
end
node.default['cassandra']['data_dir'] = data_dir
node.default['cassandra']['commitlog_dir'] = ::File.join(node['cassandra']['root_dir'], 'commitlog')
node.default['cassandra']['saved_caches_dir'] = ::File.join(node['cassandra']['root_dir'], 'saved_caches')

include_recipe 'cassandra-dse::user'
include_recipe 'cassandra-dse::repositories'

# setup repository and install datastax C* packages
case node['platform_family']
when 'debian'
  node.default['cassandra']['conf_dir'] = '/etc/cassandra'

  unless node['cassandra']['dse']
    # DataStax Server Community Edition package will not install w/o this
    # one installed. MK.
    package node['cassandra']['tools_package_name'] if node['platform_version'].to_f < 16.04

    # This is necessary because apt gets very confused by the fact that the
    # latest package available for cassandra is 2.x while you're trying to
    # install dsc12 which requests 1.2.x.
    apt_preference node['cassandra']['package_name'] do
      if node['cassandra']['release'].to_s != ''
        pin "version #{node['cassandra']['version']}-#{node['cassandra']['release']}"
      else
        pin "version #{node['cassandra']['version']}"
      end
      pin_priority '700'
    end

    apt_preference 'cassandra' do
      pin "version #{node['cassandra']['version']}"
      pin_priority '700'
    end

    package 'cassandra' do
      options '--force-yes -o Dpkg::Options::="--force-confold"'
      version node['cassandra']['version']
    end
  end

  package node['cassandra']['package_name'] do
    options '--force-yes -o Dpkg::Options::="--force-confold"'
    if node['cassandra']['release'].to_s != ''
      version "#{node['cassandra']['version']}-#{node['cassandra']['release']}"
    else
      version node['cassandra']['version']
    end
    # giving C* some time to start up
    notifies :start, 'service[cassandra]', :immediately
    notifies :run, 'ruby_block[sleep30s]', :immediately
    notifies :run, 'ruby_block[set_fd_limit]', :immediately
    notifies :run, 'execute[set_cluster_name]', :immediately
    action :install
  end

  ruby_block 'sleep30s' do
    block do
      sleep 30
    end
    action :nothing
  end

  ruby_block 'set_fd_limit' do
    block do
      file = Chef::Util::FileEdit.new("/etc/init.d/#{node['cassandra']['service_name']}")
      file.search_file_replace_line(/^FD_LIMIT=.*$/, "FD_LIMIT=#{node['cassandra']['limits']['nofile']}")
      file.write_file
    end
    retries 15
    retry_delay 1
    notifies :restart, 'service[cassandra]', :delayed
    action :nothing
  end

  execute 'set_cluster_name' do
    command "/usr/bin/cqlsh -e \"update system.local set cluster_name='#{node['cassandra']['config']['cluster_name']}' where key='local';\"; /usr/bin/nodetool flush system;"
    notifies :restart, 'service[cassandra]', :delayed
    action :nothing
  end

when 'rhel'
  node.default['cassandra']['conf_dir'] = '/etc/cassandra/conf'

  if node['cassandra']['use_systemd']
    node.default['cassandra']['startup_program'] = ::File.join(node['cassandra']['sbin_dir'], 'cassandra')
    include_recipe 'cassandra-dse::systemd'
  end

  yum_package node['cassandra']['package_name'] do
    if node['cassandra']['release'].to_s != ''
      version "#{node['cassandra']['version']}-#{node['cassandra']['release']}"
    else
      version node['cassandra']['version']
    end
    allow_downgrade
    notifies :run, 'ruby_block[set_jvm_search_dirs_on_java_8]', :immediately
    options node['cassandra']['yum']['options']
  end

  if node['cassandra']['use_systemd']
    file '/etc/init.d/' + node['cassandra']['service_name'] do
      action :delete
    end
  end

  # applying fix for java search directories, on java 8 it needs to be update
  # including the new directories
  ruby_block 'set_jvm_search_dirs_on_java_8' do
    block do
      init_path = if node['cassandra']['use_systemd']
                    ::File.join('/etc/systemd/system/', node['cassandra']['service_name'] + '.service')
                  else
                    ::File.join('/etc/init.d/', node['cassandra']['service_name'])
                  end
      f = Chef::Util::FileEdit.new(init_path)
      f.search_file_replace_line(
        /^JVM_SEARCH_DIRS=.*$/,
        'JVM_SEARCH_DIRS="/usr/lib/jvm/jre /usr/lib/jvm/jre-1.8.* /usr/lib/jvm/java-1.8.*/jre"'
      )
      f.write_file
    end
    only_if { node['java']['jdk_version'] == 8 }
    notifies :restart, 'service[cassandra]', :delayed
    action :nothing
  end

  # Creating symlink from user defined config directory to default
  directory ::File.dirname(node['cassandra']['conf_dir']) do
    owner node['cassandra']['user']
    group node['cassandra']['group']
    recursive true
    mode '0755'
  end

  link node['cassandra']['conf_dir'] do
    to node.default['cassandra']['conf_dir']
    owner node['cassandra']['user']
    group node['cassandra']['group']
    not_if { node['cassandra']['conf_dir'] == node.default['cassandra']['conf_dir'] || ::File.exist?(node['cassandra']['conf_dir']) }
  end
end

# manage C* directories
directories = [
  node['cassandra']['installation_dir'],
  node['cassandra']['conf_dir'],
  node['cassandra']['log_dir'],
  node['cassandra']['root_dir'],
  node['cassandra']['lib_dir'],
  node['cassandra']['pid_dir'],
  node['cassandra']['data_dir'],
  node['cassandra']['commitlog_dir'],
  node['cassandra']['saved_caches_dir']
]

# including hints directory, in case is part of configuration
if node['cassandra']['config'].key?('hints_directory')
  directories << node['cassandra']['config']['hints_directory']
end

directories.flatten.each do |dir|
  directory dir do
    owner node['cassandra']['user']
    group node['cassandra']['group']
    recursive true
    mode '0755'
  end
end
