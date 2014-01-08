#
# Cookbook Name:: cassandra
# Recipe:: jna
#
# Copyright 2011-2012, Paulo Motta & Chaordic Development Team
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

jna = node.cassandra.jna
remote_file "/usr/share/java/jna.jar" do
  source "#{jna.base_url}/#{jna.jar_name}"
  checksum jna.sha256sum
end

link "#{node.cassandra.lib_dir}/jna.jar" do
  to          "/usr/share/java/jna.jar"
  notifies    :restart, "service[cassandra]"
end
