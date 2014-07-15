#
# Cookbook Name:: cassandra
# Recipe:: tarball
# Copyright 2012, Michael S. Klishin <michaelklishin@me.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include_recipe "java"

# 1. Validate node.cassandra.cluster_name 
Chef::Application.fatal!("attribute node['cassandra']['cluster_name'] not defined") unless node.cassandra.cluster_name

# 2. Manage C* Service User
include_recipe "cassandra::user" if node.cassandra.setup_user

# 3. Download the tarball to /tmp
require "tmpdir"

td          = Dir.tmpdir
tmp         = File.join(td, "apache-cassandra-#{node.cassandra.version}-bin.tar.gz")
tarball_dir = File.join(td, "apache-cassandra-#{node.cassandra.version}")

#if tarball url set to 'auto' use default url 
#according to node cassandra version
if node.cassandra.tarball.url == "auto"
    node.default[:cassandra][:tarball][:url] = "http://archive.apache.org/dist/cassandra/#{node[:cassandra][:version]}/apache-cassandra-#{node[:cassandra][:version]}-bin.tar.gz"
end

remote_file tmp do
  source node.cassandra.tarball.url
  notifies :run, "bash[extract_cassandra_source]", :immediately
  not_if { File.exists?(node.cassandra.source_dir) }
end

# 4. Extract it
# 5. Copy to node.cassandra.installation_dir, update permissions
bash "extract_cassandra_source" do
  user  "root"
  cwd   "/tmp"

  code <<-EOS
    tar xzf #{tmp}
    mv --force #{tarball_dir} #{node.cassandra.source_dir}
    chown -R #{node.cassandra.user}:#{node.cassandra.group} #{node.cassandra.source_dir}
  EOS

  creates "#{node.cassandra.source_dir}/bin/cassandra"
  action  :nothing
end

# 6. Create and Change Ownership C* directories

directory node.cassandra.source_dir do
  owner     node.cassandra.user
  group     node.cassandra.group
  recursive true
  mode      0755
  action    :create
end

link node.cassandra.installation_dir do
  to node.cassandra.source_dir
  owner     node.cassandra.user
  group     node.cassandra.group
  action :create
end

[ node.cassandra.log_dir,
  node.cassandra.pid_dir,
  node.cassandra.lib_dir,
  node.cassandra.root_dir,
  node.cassandra.conf_dir,
  File.join(node.cassandra.installation_dir, "system"),
].each do |dir|
  directory dir do
    owner     node.cassandra.user
    group     node.cassandra.group
    recursive true
    mode      0755
    action    :create
  end
end

# 7. Create and Change Ownership C* log files
[File.join(node.cassandra.log_dir, 'system.log'), File.join(node.cassandra.log_dir, 'boot.log')].each {|f|
  file f do
    owner node.cassandra.user
    group node.cassandra.group
    mode 0644
    action :create
  end
}

# 8. Create/Update C* Configuration Files / Binaries
%w(cassandra.yaml cassandra-env.sh log4j-server.properties).each do |f|
  template File.join(node.cassandra.conf_dir, f) do
    source "#{f}.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  0644
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

if node.cassandra.snitch_conf
  template File.join(node.cassandra.conf_dir, "cassandra-topology.properties") do
    source "cassandra-topology.properties.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  0644
    variables ({ :snitch => node.cassandra.snitch_conf })
  end
end

if node.cassandra.attribute?("rackdc")
  template File.join(node.cassandra.conf_dir, "cassandra-rackdc.properties") do
    source "cassandra-rackdc.properties.erb"
    owner node.cassandra.user
    group node.cassandra.group
    mode  0644
    variables ({ :rackdc => node.cassandra.rackdc })
  end
end

template File.join(node.cassandra.bin_dir, "cassandra-cli") do
  source "cassandra-cli.erb"
  owner node.cassandra.user
  group node.cassandra.group
  mode  0755
end

template "#{node.cassandra.installation_dir}/bin/cqlsh" do
  source "cqlsh.erb"
  owner node.cassandra.user
  group node.cassandra.group
  mode  0755
  not_if { File.exists?("#{node.cassandra.installation_dir}/bin/cqlsh")  }
end

# 9. Symlink C* Binaries 
%w(cqlsh cassandra cassandra-shell cassandra-cli).each do |f|
  link "/usr/local/bin/#{f}" do
    owner node.cassandra.user
    group node.cassandra.group
    to    "#{node.cassandra.installation_dir}/bin/#{f}"
    only_if  { File.exists?("#{node.cassandra.installation_dir}/bin/#{f}") }
  end
end

# 10. Set C* Service User ulimits
user_ulimit "cassandra" do
  filehandle_limit node.cassandra.limits.nofile
  process_limit node.cassandra.limits.nproc
  memory_limit node.cassandra.limits.memlock
end

ruby_block "require_pam_limits.so" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/pam.d/su")
    fe.search_file_replace_line(/# session    required   pam_limits.so/, "session    required   pam_limits.so")
    fe.write_file
  end
end

# 11. init.d Service
template "/etc/init.d/#{node.cassandra.service_name}" do
  source "#{node.platform_family}.cassandra.init.erb"
  owner 'root'
  group 'root'
  mode  0755
end

# 12. Setup JNA
if node.cassandra.setup_jna
  jna = node.cassandra.jna
  remote_file "/usr/share/java/jna.jar" do
    source "#{jna.base_url}/#{jna.jar_name}"
    checksum jna.sha256sum
  end

  link "#{node.cassandra.lib_dir}/jna.jar" do
    to "/usr/share/java/jna.jar"
    notifies :restart, "service[cassandra]", :delayed if node.cassandra.notify_restart
  end
end

# 13. Ensure C* Service is running
service "cassandra" do
  supports :start => true, :stop => true, :restart => true, :status => true
  service_name node.cassandra.service_name
  action [:enable, :start]
end

# 14. Cleanup
remote_file tmp do
  action :delete
end
