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

include_recipe "java"

user node.cassandra.user do
  comment "Cassandra Server user"
  home    node.cassandra.installation_dir
  shell   "/bin/bash"
  action  :create
end

group node.cassandra.user do
  (m = []) << node.cassandra.user
  members m
  action :create
end

[node.cassandra.data_root_dir, node.cassandra.log_dir, node.cassandra.commitlog_dir].each do |dir|
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
    mode  0644
    notifies :restart, "service[cassandra]", :delayed
  end
end

service "cassandra" do
  supports :restart => true, :status => true
  service_name node.cassandra.service_name
  action [:enable, :start]
end
