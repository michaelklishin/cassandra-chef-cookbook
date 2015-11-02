#
# Cookbook Name:: cassandra-dse
# Recipe:: tarball
# Copyright 2012-2015, Michael S. Klishin and Travis CI Development Team <michael@clojurewerkz.org>
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

node.default['cassandra']['source_dir'] = '/usr/local/apache-cassandra-' + node['cassandra']['version']

node.default['cassandra']['installation_dir'] = '/usr/local/cassandra'

# node['cassandra']['installation_dir'] subdirs
node.default['cassandra']['bin_dir']   = ::File.join(node['cassandra']['installation_dir'], 'bin')
node.default['cassandra']['lib_dir']   = ::File.join(node['cassandra']['installation_dir'], 'lib')
node.default['cassandra']['conf_dir']  = ::File.join(node['cassandra']['installation_dir'], 'conf')

# commit log, data directory, saved caches and so on are all stored under the data root. MK.
# node['cassandra']['root_dir sub dirs
node.default['cassandra']['data_dir'] = [::File.join(node['cassandra']['root_dir'], 'data')]
node.default['cassandra']['commitlog_dir'] = ::File.join(node['cassandra']['root_dir'], 'commitlog')
node.default['cassandra']['saved_caches_dir'] = ::File.join(node['cassandra']['root_dir'], 'saved_caches')

# manage C* service user
include_recipe 'cassandra-dse::user'

require 'tmpdir'

td = Dir.tmpdir
tmp = ::File.join(td, "apache-cassandra-#{node['cassandra']['version']}-bin.tar.gz")
tarball_dir = ::File.join(td, "apache-cassandra-#{node['cassandra']['version']}")

# if tarball url set to 'auto' use default url
# according to node cassandra version
if node['cassandra']['tarball']['url'] == 'auto'
  node.default['cassandra']['tarball']['url'] = "http://archive.apache.org/dist/cassandra/#{node['cassandra']['version']}/apache-cassandra-#{node['cassandra']['version']}-bin.tar.gz"
end

# stop C* service during upgrades
service 'cassandra' do
  service_name node['cassandra']['service_name']
  action :stop
  only_if { ::File.exist?("/etc/init.d/#{node['cassandra']['service_name']}") && !::File.exist?(node['cassandra']['source_dir']) }
end

tarball_checksum = node['cassandra']['tarball']['sha256sum'] || tarball_sha256sum(node['cassandra']['version'])

# download C* tarball to /tmp
remote_file tmp do
  source node['cassandra']['tarball']['url']
  checksum tarball_checksum
  not_if { ::File.exist?(node['cassandra']['source_dir']) }
end

# extract archive to node['cassandra']['source_dir'] and update one time ownership permissions
bash 'extract_cassandra_source' do
  user 'root'
  cwd td

  code <<-EOS
    tar xzf #{tmp}
    mv --force #{tarball_dir} #{node['cassandra']['source_dir']}
    chown -R #{node['cassandra']['user']}:#{node['cassandra']['group']} #{node['cassandra']['source_dir']}
    chmod #{node['cassandra']['dir_mode']} #{node['cassandra']['source_dir']}
  EOS

  not_if  { ::File.exist?(node['cassandra']['source_dir']) }
  creates ::File.join(node['cassandra']['source_dir'], 'bin', 'cassandra')
  action :run
end

# link node['cassandra']['source_dir'] to node['cassandra']['installation_dir']
link node['cassandra']['installation_dir'] do
  to node['cassandra']['source_dir']
  owner node['cassandra']['user']
  group node['cassandra']['group']
end

# manage C* directories
directories = [node['cassandra']['log_dir'],
               node['cassandra']['pid_dir'],
               node['cassandra']['lib_dir'],
               node['cassandra']['root_dir'],
               node['cassandra']['conf_dir']
              ]
directories += node['cassandra']['data_dir'] # this is an array now
directories.each do |dir|
  directory dir do
    owner node['cassandra']['user']
    group node['cassandra']['group']
    recursive true
    mode 0755
  end
end

# setup C* binaries
template ::File.join(node['cassandra']['bin_dir'], 'cassandra-cli') do
  source 'cassandra-cli.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode 0755
end

template ::File.join(node['cassandra']['installation_dir'], 'bin', 'cqlsh') do
  source 'cqlsh.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode 0755
  not_if { ::File.exist?(::File.join(node['cassandra']['installation_dir'], 'bin', 'cqlsh')) }
end

%w(cqlsh cassandra cassandra-shell cassandra-cli).each do |f|
  link "/usr/local/bin/#{f}" do
    owner node['cassandra']['user']
    group node['cassandra']['group']
    to ::File.join(node['cassandra']['installation_dir'], 'bin', f)
    only_if { ::File.exist?(::File.join(node['cassandra']['installation_dir'], 'bin', f)) }
  end
end

# setup ulimits
#
# Perhaps we can move it to recipe `config`
user_ulimit node['cassandra']['user'] do
  filehandle_limit node['cassandra']['limits']['nofile']
  process_limit node['cassandra']['limits']['nproc']
  memory_limit node['cassandra']['limits']['memlock']
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end

pam_limits = 'session    required   pam_limits.so'
ruby_block 'require_pam_limits.so' do
  block do
    fe = Chef::Util::FileEdit.new('/etc/pam.d/su')
    fe.search_file_replace_line(/# #{pam_limits}/, pam_limits)
    fe.write_file
  end
  only_if { ::File.readlines('/etc/pam.d/su').grep(/# #{pam_limits}/).any? }
end

# sysv service file
template "/etc/init.d/#{node['cassandra']['service_name']}" do
  source "#{node['platform_family']}.cassandra.init.erb"
  owner 'root'
  group 'root'
  mode 0755
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end

# 15. Cleanup
remote_file tmp do
  action :delete
end

# purge older versions
ruby_block 'purge-old-tarball' do
  block do
    require 'fileutils'
    installed_versions = Dir.entries('/usr/local').reject { |a| a !~ /^apache-cassandra/ }.sort
    old_versions = installed_versions - ["apache-cassandra-#{node['cassandra']['version']}"]

    old_versions.each do |v|
      v = "/usr/local/#{v}"
      FileUtils.rm_rf Dir.glob(v)
      Chef::Log.warn("deleted older C* tarball archive #{v}")
    end
  end
  only_if { node['cassandra']['tarball_purge'] }
end
