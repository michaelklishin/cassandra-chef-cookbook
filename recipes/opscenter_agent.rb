
include_recipe "ark"
include_recipe "runit"

ark "#{node[:cassandra][:opscenter][:agent][:install_folder_name]}" do
  path node[:cassandra][:opscenter][:agent][:install_dir]
  url node[:cassandra][:opscenter][:agent][:download_url]
  checksum node[:cassandra][:opscenter][:agent][:checksum]
  action :put
end

server_ip = node[:cassandra][:opscenter][:agent][:server_host]
if server_ip.empty?
  search_results = search(:node, "roles:#{node[:cassandra][:opscenter][:agent][:server_role]}")
  unless search_results.empty?
    server_ip = search_results[0]['ipaddress']
  else
    raise "Can't locate opscenter server IP address"
  end
end 

agent_dir = "#{node[:cassandra][:opscenter][:agent][:install_dir]}/#{node[:cassandra][:opscenter][:agent][:install_folder_name]}"

execute "configure agent" do
  cwd agent_dir
  command "bin/setup #{server_ip}"
  not_if { node.attribute?("opscenter_agent_setup_run") } # Run setup just once
  notifies :create, "ruby_block[set_setup_run_flag]", :immediately
end

ruby_block "set_setup_run_flag" do
  block do
    node.set['opscenter_agent_setup_run'] = true
    node.save
  end
  action :nothing
end

runit_service "opscenter-agent" do
  action :start
  default_logger true
  options ({
    :dir => agent_dir
  })
end
