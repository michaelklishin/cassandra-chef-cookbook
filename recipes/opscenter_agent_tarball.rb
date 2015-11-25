#
# Cookbook Name:: cassandra-dse
# Recipe:: opscenter_agent_tarball
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

include_recipe 'ark'

ark node['cassandra']['opscenter']['agent']['install_folder_name'] do
  path node['cassandra']['opscenter']['agent']['install_dir']
  url node['cassandra']['opscenter']['agent']['download_url']
  checksum node['cassandra']['opscenter']['agent']['checksum'] if node['cassandra']['opscenter']['agent']['checksum']
  action :put
end

server_ip = node['cassandra']['opscenter']['agent']['server_host']
unless server_ip && !node['cassandra']['opscenter']['agent']['use_chef_search']

  unless Chef::Config[:solo]
    search_results = search(:node, "roles:#{node['cassandra']['opscenter']['agent']['server_role']}")
    if !search_results.empty?
      server_ip = search_results[0]['ipaddress']
    else
      return # Continue until opscenter will come up
    end
  end

end

agent_dir = ::File.join(node['cassandra']['opscenter']['agent']['install_dir'], node['cassandra']['opscenter']['agent']['install_folder_name'])

template "#{agent_dir}/conf/address.yaml" do
  mode 0644
  source 'opscenter-agent.conf.erb'
  variables(:server_ip => server_ip)
  notifies :restart, 'service[opscenter-agent]'
end

binary_name = node['cassandra']['opscenter']['agent']['binary_name']
binary_grep_str = "[#{binary_name[0]}]#{binary_name[1..-1]}"

service 'opscenter-agent' do
  provider Chef::Provider::Service::Simple
  supports :start => true, :status => true, :stop => true
  start_command "#{agent_dir}/bin/#{binary_name}"
  status_command "ps aux | grep -q '#{binary_grep_str}'"
  stop_command "kill $(ps aux | grep '#{binary_grep_str}' | awk '{print $2}')"
  action :start
end
