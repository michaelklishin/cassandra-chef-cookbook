#
# Cookbook Name:: cassandra-dse
# Recipe:: opscenter_agent
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

Chef::Log.warn('cassandra-dse::opscenter_agent is deprecated, please use cassandra-dse::opscenter_agent_tarball or cassandra-dse::opscenter_agent_datastax')
include_recipe 'cassandra-dse::opscenter_agent_tarball'
