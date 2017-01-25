# generate profile file with environment variables necessary to run nodetool

template ::File.join('/etc/profile.d', node['cassandra']['service_name'] + '.sh') do
  source 'cassandra.envvars.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
