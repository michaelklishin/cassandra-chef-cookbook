include_recipe "java"

case node["platform_family"]
when "debian"

  if node['cassandra']['dse']
    dse = node['cassandra']['dse']
    if dse['credentials']['databag']
      dse_credentials = Chef::EncryptedDataBagItem.load(dse['credentials']['databag']['name'], dse['credentials']['databag']['item'])[dse['credentials']['databag']['entry']]
    else
      dse_credentials = dse['credentials']
    end
    apt_repository "datastax" do
      uri          "http://#{dse_credentials['username']}:#{dse_credentials['password']}@debian.datastax.com/enterprise"
      distribution "stable"
      components   ["main"]
      key          "https://debian.datastax.com/debian/repo_key"
      action :add
    end
  else
    apt_repository "datastax" do
      uri          "https://debian.datastax.com/community"
      distribution "stable"
      components   ["main"]
      key          "https://debian.datastax.com/debian/repo_key"
      action :add
    end
  end

when "rhel"
  include_recipe "yum"

  yum_repository "datastax" do
    description "DataStax Repo for Apache Cassandra"
    baseurl "http://rpm.datastax.com/community"
    gpgcheck false
    action :create
  end
end

server_ip = node[:cassandra][:opscenter][:agent][:server_host]
if !server_ip
  search_results = search(:node, "roles:#{node[:cassandra][:opscenter][:agent][:server_role]}")
  unless search_results.empty?
    server_ip = search_results[0]['ipaddress']
  else
    return # Continue until opscenter will come up
  end
end 

package "#{node[:cassandra][:opscenter][:agent][:package_name]}" do
  action :install
end

service "datastax-agent" do
  supports :restart => true, :status => true
  action [:enable, :start]
end


template "/etc/datastax-agent/address.yaml" do
  mode 0644
  source "opscenter-agent.conf.erb"
  variables({
    :server_ip => server_ip
  })
  notifies :restart, "service[datastax-agent]"
end
