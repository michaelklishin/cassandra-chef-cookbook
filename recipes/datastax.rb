#
# Cookbook Name:: cassandra
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

# This recipe relies on a PPA package and is Ubuntu/Debian specific. Please
# keep this in mind.

apt_repository "datastax" do
  uri          "https://debian.datastax.com/community"
  distribution "stable"
  components   ["main"]
  key          "https://debian.datastax.com/debian/repo_key"

  action :add
end

# DataStax Server Community Edition package will not install w/o this
# one installed. MK.
package "python-cql" do
  action :install
end

# This is necessary because apt gets very confused by the fact that the
# latest package available for cassandra is 2.x while you're trying to 
# install dsc12 which requests 1.2.x.
if node[:platform_family] == "debian" then
  package "cassandra" do
    action :install
    version node[:cassandra][:version]
  end
end


package "dsc12" do
  action :install
  version node[:cassandra][:dscversion]
end

service "cassandra" do
  supports :restart => true, :status => true
  action [:enable, :start]
end
