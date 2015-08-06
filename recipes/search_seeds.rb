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

node.override['cassandra']['seeds'] =
    if Chef::Config[:solo]
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
      node['ipaddress']
    else
      xs = search(:node, "role:cassandra-seed") + search(:node, "role:cassandra")
      if xs.empty?
        node['ipaddress']
      else
        xs.take(3).sort.map { |x| x['ipaddress'] }
      end
    end

include_recipe "cassandra-dse::default"
