#
# Cookbook Name:: cassandra-dse
# Recipe:: opscenter_agent_datastax
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

include_recipe 'java' if node['cassandra']['install_java']
include_recipe 'cassandra-dse::repositories'

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

ops = node['cassandra']['opscenter']
ops_agent = ops['agent']

package ops_agent['package_name'] do
  version ops['version']
  options node['cassandra']['yum']['options'] if node['platform_family'] == 'rhel'
end

service 'datastax-agent' do
  supports :restart => true, :status => true
  action [:enable, :start]
  subscribes :restart, "package[#{ops_agent['package_name']}]"
end

template ::File.join(node['cassandra']['opscenter']['agent']['conf_dir'], 'address.yaml') do
  mode 0644
  owner node['cassandra']['user']
  group node['cassandra']['group']
  source 'opscenter-agent.conf.erb'
  variables(:server_ip => server_ip)
  notifies :restart, 'service[datastax-agent]'
end
