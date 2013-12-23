default[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :version => '2.0.3',
  :user => "cassandra",
  :jvm  => {
    :xms => 32,
    :xmx => 512
  },
  :limits => {
    :memlock => 'unlimited',
    :nofile  => 48000
  },
  :templates_cookbook => "cassandra",
  :installation_dir => "/usr/local/cassandra",
  :bin_dir          => "/usr/local/cassandra/bin",
  :lib_dir          => "/usr/local/cassandra/lib",
  :conf_dir         => "/etc/cassandra/",
  # commit log, data directory, saved caches and so on are all stored under the data root. MK.
  :data_root_dir    => "/var/lib/cassandra/",
  :commitlog_dir    => "/var/lib/cassandra/",
  :log_dir          => "/var/log/cassandra/",
  :listen_address   => node[:ipaddress],
  :start_rpc        => "true",
  :rpc_address      => node[:ipaddress],
  :rpc_port         => "9160",
  :start_native_transport  => "true",
  :native_transport_port   => "9042",
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :vnodes           => false,
  :seeds            => [],
  :concurrent_reads => 32,
  :concurrent_writes => 32,
  :snitch           => 'SimpleSnitch',
  :package_name     => 'dsc12',
  :snitch_conf      => false
}
default[:cassandra][:tarball] = {
  :url => "http://archive.apache.org/dist/cassandra/#{node[:cassandra][:version]}/apache-cassandra-#{node[:cassandra][:version]}-bin.tar.gz",
  :md5 => "98d266fa0b84b50971e87f0c905bf2df"
}

default[:cassandra][:opscenter][:server] = {
  :package_name => "opscenter-free"
}

default[:cassandra][:opscenter][:agent] = {
  :download_url => nil,
  :checksum => nil,
  :install_dir => "/opt",
  :install_folder_name => "opscenter_agent",
  :server_host => nil, # if nil, will use search to get IP by server role
  :server_role => "opscenter_server",
  :use_ssl => true
}
