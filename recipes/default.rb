#
# Cookbook Name:: cassandra-dse
# Recipe:: default
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

fail "attribute node['cassandra']['config']['cluster_name'] not defined" unless node['cassandra']['config']['cluster_name']

# discover cluster nodes via chef search
node.default['cassandra']['seeds'] = discover_seed_nodes

# setup java
include_recipe 'java' if node['cassandra']['install_java']

# install C* via datastax / tarball
include_recipe "cassandra-dse::#{node['cassandra']['install_method']}"

# configues C*
include_recipe 'cassandra-dse::config'
