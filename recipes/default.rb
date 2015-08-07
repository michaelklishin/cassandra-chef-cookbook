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

case node['cassandra']['version']
# Submit an issue if jamm version is not correct for 0.x or 1.x version
when /^0\./, /^1\./, /^2\.0/
  # < 2.1 Versions
  node.default['cassandra']['log_config_files'] = %w(log4j-server.properties)
  node.default['cassandra']['jamm_version'] = '0.2.5'
  node.default['cassandra']['jamm']['base_url'] = "http://repo1.maven.org/maven2/com/github/stephenc/jamm/#{node.attribute['cassandra']['jamm_version']}"
  node.default['cassandra']['jamm']['jar_name'] = "jamm-#{node.attribute['cassandra']['jamm_version']}.jar"
  node.default['cassandra']['jamm']['sha256sum'] = 'e3dd1200c691f8950f51a50424dd133fb834ab2ce9920b05aa98024550601cc5'
else
  # >= 2.1 Version
  node.default['cassandra']['log_config_files'] = %w(logback.xml logback-tools.xml)
  node.default['cassandra']['jamm_version'] = '0.2.8'
  node.default['cassandra']['jamm']['base_url'] = "http://repo1.maven.org/maven2/com/github/jbellis/jamm/#{node.attribute['cassandra']['jamm_version']}"
  node.default['cassandra']['jamm']['jar_name'] = "jamm-#{node.attribute['cassandra']['jamm_version']}.jar"
  node.default['cassandra']['jamm']['sha256sum'] = '79d44f1b911a603f0a249aa59ad6ea22aac9c9b211719e86f357646cdf361a42'
end

node.default['cassandra']['seeds'] = discover_seed_nodes

include_recipe "cassandra-dse::#{node['cassandra']['install_method']}"
