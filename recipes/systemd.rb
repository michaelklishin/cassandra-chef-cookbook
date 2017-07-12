# generate systemd service
#

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template ::File.join(node['systemd']['units_dir'], node['cassandra']['service_name'] + '.service') do
  source 'cassandra.service.erb'
  owner node['cassandra']['user']
  group node['cassandra']['group']
  mode '0644'
  notifies :run, 'execute[daemon-reload]', :immediately
  notifies :enable, 'service[cassandra]', :delayed
  notifies :restart, 'service[cassandra]', :delayed if node['cassandra']['notify_restart']
end
