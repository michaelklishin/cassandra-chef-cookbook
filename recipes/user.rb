#
# Cookbook Name:: cassandra
# Recipe:: user
#
# Copyright 2014, Virender Khatri <vir.khatri@gmail.com>
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

group node['cassandra']['group'] do
  system node['cassandra']['system_user'] # ~FC048
  action :create
end

user node['cassandra']['user'] do
  comment 'Cassandra Server user'
  gid node['cassandra']['group']
  home node['cassandra']['user_home'] if node['cassandra']['user_home']
  system node['cassandra']['system_user'] # ~FC048
  shell '/bin/bash'
  action :create
end

group node['cassandra']['group'] do
  members [node['cassandra']['user']]
  append true
  action :modify
end
