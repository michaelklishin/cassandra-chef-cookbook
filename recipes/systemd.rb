# generate systemd service
#

systemd_service 'cassandra' do
  description 'cassandra daemon'
  wants 'network-online.target'
  after 'network-online.target'
  install do
    wanted_by 'multi-user.target'
  end
  service do
    type 'oneshot'
    standard_output 'journal'
    standard_error 'inherit'
    environment 'CASSANDRA_HOME' => node.cassandra.installation_dir, \
	    'CASSANDRA_CONF' => node.cassandra.conf_dir
    pid_file "#{node.cassandra.pid_dir}/cassandra.pid"
    exec_start "#{node.cassandra.installation_dir}/bin/cassandra -p #{node.cassandra.pid_dir}/cassandra.pid"
    exec_stop "#{node.cassandra.installation_dir}/bin/nodetool -h #{node.ipaddress} disablethrift ; " \
	    "#{node.cassandra.installation_dir}/bin/nodetool -h #{node.ipaddress} disablegossip ; " \
	    "#{node.cassandra.installation_dir}/bin/nodetool -h #{node.ipaddress} drain ; " \
	    "/bin/kill $MAINPID"
    user node.cassandra.user
    group node.cassandra.group
    limit_nofile 'infinity'
  end
end
