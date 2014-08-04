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

# This recipe relies on a PPA package and is Ubuntu/Debian specific. Please
# keep this in mind.

node.default[:cassandra][:conf_dir] = '/etc/cassandra/'

include_recipe "java"

Chef::Application.fatal!("attribute node['cassandra']['cluster_name'] not defined") unless node.cassandra.cluster_name

include_recipe "cassandra::user" if node.cassandra.setup_user

[node.cassandra.root_dir,
  node.cassandra.log_dir,
  node.cassandra.commitlog_dir,
  node.cassandra.installation_dir,
  node.cassandra.bin_dir,
  node.cassandra.lib_dir,
  node.cassandra.conf_dir].each do |dir|

  directory dir do
    owner     node.cassandra.user
    group     node.cassandra.user
    recursive true
    action    :create
  end
end

case node["platform_family"]
when "debian"
  if node['cassandra']['dse']
    dse = node.cassandra.dse
    if dse.credentials.databag
      dse_credentials = Chef::EncryptedDataBagItem.load(dse.credentials.databag.name, dse.credentials.databag.item)[dse.credentials.databag.entry]
    else
      dse_credentials = dse.credentials
    end

    package "apt-transport-https"

    apt_repository "datastax" do
      uri          "http://#{dse_credentials['username']}:#{dse_credentials['password']}@debian.datastax.com/enterprise"
      distribution "stable"
      components   ["main"]
      key          "http://debian.datastax.com/debian/repo_key"
      action :add
    end
  else
    apt_repository "datastax" do
      uri          "http://debian.datastax.com/community"
      distribution "stable"
      components   ["main"]
      key          "http://debian.datastax.com/debian/repo_key"

      action :add
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
      end
      apt_preference "cassandra" do
        pin "version #{node.cassandra.version}"
        pin_priority "700"
      end
    end
  end

when "rhel"
  include_recipe "yum"

  yum_repository "datastax" do
    description "DataStax Repo for Apache Cassandra"
    baseurl "http://rpm.datastax.com/community"
    gpgcheck false
    action :create
  end

  yum_package "#{node.cassandra.package_name}" do
    version "#{node.cassandra.version}-#{node.cassandra.release}"
    allow_downgrade
  end

end

%w(cassandra.yaml cassandra-env.sh).each do |f|
  template File.join(node.cassandra.conf_dir, f) do
    cookbook node.cassandra.templates_cookbook
    source "#{f}.erb"
    owner node.cassandra.user
    group node.cassandra.user
    mode  "0644"
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

service "cassandra" do
  supports :restart => true, :status => true
  service_name node.cassandra.service_name
  action [:nothing]
end
