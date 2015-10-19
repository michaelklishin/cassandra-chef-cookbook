#
# Cookbook Name:: cassandra-dse
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

if node['cassandra']['dse']
  dse = node['cassandra']['dse']
  if dse['credentials']['databag']
    dse_credentials = Chef::EncryptedDataBagItem.load(dse['credentials']['databag']['name'], dse['credentials']['databag']['item'])[dse['credentials']['databag']['entry']]
  else
    dse_credentials = dse['credentials']
  end
end

case node['platform_family']
when 'debian'
  package 'apt-transport-https'

  apt_repository node['cassandra']['apt']['repo'] do
    if node['cassandra']['dse']
      uri "https://#{dse_credentials['username']}:#{dse_credentials['password']}@debian.datastax.com/enterprise"
    else
      uri node['cassandra']['apt']['uri']
    end
    distribution node['cassandra']['apt']['distribution']
    components node['cassandra']['apt']['components']
    key node['cassandra']['apt']['repo_key']
    action node['cassandra']['apt']['action']
  end
when 'rhel'
  include_recipe 'yum'

  yum_repository node['cassandra']['yum']['repo'] do
    if node['cassandra']['dse']
      baseurl "https://#{dse_credentials['username']}:#{dse_credentials['password']}@rpm.datastax.com/enterprise"
    else
      baseurl node['cassandra']['yum']['baseurl']
    end
    description node['cassandra']['yum']['description']
    mirrorlist node['cassandra']['yum']['mirrorlist'] unless node['cassandra']['yum']['mirrorlist'].nil?
    gpgcheck node['cassandra']['yum']['gpgcheck']
    enabled node['cassandra']['yum']['enabled']
    action node['cassandra']['yum']['action']
  end
end
