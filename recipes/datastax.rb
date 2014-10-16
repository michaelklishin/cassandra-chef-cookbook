#
# Cookbook Name:: cassandra
# Recipe:: datastax
#
# Copyright 2011-2012, Michael S Klishin & Travis CI Development Team
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

Chef::Application.fatal!("attribute node['cassandra']['cluster_name'] not defined") unless node.cassandra.cluster_name

node.default[:cassandra][:installation_dir] = "/usr/share/cassandra"
# node.cassandra.installation_dir subdirs
node.default[:cassandra][:bin_dir]   = File.join(node.cassandra.installation_dir, 'bin')
node.default[:cassandra][:lib_dir]   = File.join(node.cassandra.installation_dir, 'lib')

# commit log, data directory, saved caches and so on are all stored under the data root. MK.
# node.cassandra.root_dir sub dirs
node.default[:cassandra][:data_dir] = File.join(node.cassandra.root_dir, 'data')
node.default[:cassandra][:commitlog_dir] = File.join(node.cassandra.root_dir, 'commitlog')
node.default[:cassandra][:saved_caches_dir] = File.join(node.cassandra.root_dir, 'saved_caches')

if node[:cassandra][:install_java] then
  include_recipe "java"
end

include_recipe "cassandra::user" if node.cassandra.setup_user

case node["platform_family"]
when "debian"
  node.default[:cassandra][:conf_dir]  = "/etc/cassandra"

  if node['cassandra']['dse']
    dse = node.cassandra.dse
    if dse.credentials.databag
      dse_credentials = Chef::EncryptedDataBagItem.load(dse.credentials.databag.name, dse.credentials.databag.item)[dse.credentials.databag.entry]
    else
      dse_credentials = dse.credentials
    end

    package "apt-transport-https"

    apt_repository  node.cassandra.apt.repo do
      uri           "http://#{dse_credentials['username']}:#{dse_credentials['password']}@debian.datastax.com/enterprise"
      distribution  node.cassandra.apt.distribution
      components    node.cassandra.apt.components
      key           node.cassandra.apt.repo_key
      action        node.cassandra.apt.action
    end
  else
    apt_repository  node.cassandra.apt.repo do
      uri           node.cassandra.apt.uri
      distribution  node.cassandra.apt.distribution
      components    node.cassandra.apt.components
      key           node.cassandra.apt.repo_key
      action        node.cassandra.apt.action
    end

    # DataStax Server Community Edition package will not install w/o this
    # one installed. MK.
    package "python-cql" do
      action :install
    end

    # This is necessary because apt gets very confused by the fact that the
    # latest package available for cassandra is 2.x while you're trying to
    # install dsc12 which requests 1.2.x.
    if node[:platform_family] == "debian" then
      package "cassandra" do
        action :install
        version node.cassandra.version
        # giving C* some time to start up
        notifies  :run, "ruby_block[sleep30s]", :immediately
        notifies  :run, "execute[set_cluster_name]", :immediately
      end
      apt_preference "cassandra" do
        pin "version #{node.cassandra.version}"
        pin_priority "700"
      end
    end
  end

  ruby_block "sleep30s" do
    block do
      sleep 30
    end
    action  :nothing
  end

  execute "set_cluster_name" do
    command   "/usr/bin/cqlsh -e \"update system.local set cluster_name='#{node.cassandra.cluster_name}' where key='local';\"; /usr/bin/nodetool flush;"
    notifies  :restart, "service[cassandra]", :delayed
    action    :nothing
  end

when "rhel"
  node.default[:cassandra][:conf_dir]  = "/etc/cassandra/conf"
  include_recipe "yum"

  if node['cassandra']['dse']
    dse = node.cassandra.dse
    if dse.credentials.databag
      dse_credentials = Chef::EncryptedDataBagItem.load(dse.credentials.databag.name, dse.credentials.databag.item)[dse.credentials.databag.entry]
    else
      dse_credentials = dse.credentials
    end

    yum_repository node.cassandra.yum.repo do
      description   node.cassandra.yum.description
      baseurl       "http://#{dse_credentials['username']}:#{dse_credentials['password']}@rpm.datastax.com/enterprise"
      mirrorlist    node.cassandra.yum.mirrorlist
      gpgcheck      node.cassandra.yum.gpgcheck
      enabled       node.cassandra.yum.enabled
      action        node.cassandra.yum.action
    end

  else
    yum_repository node.cassandra.yum.repo do
      description   node.cassandra.yum.description
      baseurl       node.cassandra.yum.baseurl
      mirrorlist    node.cassandra.yum.mirrorlist
      gpgcheck      node.cassandra.yum.gpgcheck
      enabled       node.cassandra.yum.enabled
      action        node.cassandra.yum.action
    end
  end

  yum_package node.cassandra.package_name do
    version "#{node.cassandra.version}-#{node.cassandra.release}"
    allow_downgrade
    options node.cassandra.yum.options
  end

  # Creating symlink from user defined config directory to default
  directory File.dirname(node.cassandra.conf_dir) do
    owner     node.cassandra.user
    group     node.cassandra.group
    recursive true
    mode      0755
    action    :create
  end
  link node.cassandra.conf_dir do
    to        node.default[:cassandra][:conf_dir]
    owner     node.cassandra.user
    group     node.cassandra.group
    action    :create
    not_if    do node.cassandra.conf_dir == node.default[:cassandra][:conf_dir] end
  end
end

# These are required irrespective of package construction.
# node.cassandra.root_dir sub dirs need not to be managed by Chef,
# C* service creates sub dirs with right user perm set.
# Disabling, will keep entries till next commit.
#
[node.cassandra.installation_dir,
  node.cassandra.bin_dir,
  node.cassandra.log_dir,
  node.cassandra.root_dir,
  node.cassandra.lib_dir].each do |dir|
  directory dir do
    owner     node.cassandra.user
    group     node.cassandra.group
    recursive true
    mode      0755
    action    :create
  end
end

%w(cassandra.yaml cassandra-env.sh).each do |f|
  template File.join(node.cassandra.conf_dir, f) do
    cookbook node.cassandra.templates_cookbook
    source "#{f}.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  "0644"
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end


node.cassandra.log_config_files.each do |f|
  template File.join(node.cassandra.conf_dir, f) do
    cookbook node.cassandra.templates_cookbook
    source "#{f}.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  "0644"
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

if node.cassandra.attribute?("rackdc")
  template File.join(node.cassandra.conf_dir, "cassandra-rackdc.properties") do
    source "cassandra-rackdc.properties.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  0644
    variables ({ :rackdc => node.cassandra.rackdc })
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

[File.join(node.cassandra.log_dir, 'system.log'), File.join(node.cassandra.log_dir, 'boot.log')].each {|f|
  file f do
    owner node.cassandra.user
    group node.cassandra.group
    mode  "0644"
    action :create
  end
}

directory '/usr/share/java' do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

if node.cassandra.setup_jna
  remote_file "/usr/share/java/jna.jar" do
    source "#{node.cassandra.jna.base_url}/#{node.cassandra.jna.jar_name}"
    checksum node.cassandra.jna.sha256sum
  end

  link "#{node.cassandra.lib_dir}/jna.jar" do
    to          "/usr/share/java/jna.jar"
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

if node.cassandra.setup_jamm
  remote_file "/usr/share/java/#{node[:cassandra][:jamm][:jar_name]}" do
    source "#{node[:cassandra][:jamm][:base_url]}/#{node[:cassandra][:jamm][:jar_name]}"
    checksum node.cassandra.jamm.sha256sum
  end

  link "#{node.cassandra.lib_dir}/#{node.cassandra.jamm.jar_name}" do
    to          "/usr/share/java/#{node.cassandra.jamm.jar_name}"
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

service "cassandra" do
  supports :restart => true, :status => true
  service_name node.cassandra.service_name
  action node.cassandra.service_action
end
