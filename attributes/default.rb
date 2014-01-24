default[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :version => '2.0.4',
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
  :max_hint_window_in_ms=> 10800000, # 3 hours
  :listen_address   => node[:ipaddress],
  :partitioner      => "org.apache.cassandra.dht.Murmur3Partitioner",
  :key_cache_size_in_mb => "",
  :broadcast_address => node[:ipaddress],
  :start_rpc        => "true",
  :rpc_address      => node[:ipaddress],
  :rpc_port         => "9160",
  :range_request_timeout_in_ms => 10000,
  :streaming_socket_timeout_in_ms => 0, #never timeout streams
  :start_native_transport  => "true",
  :native_transport_port   => "9042",
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :xss              => "256k",
  :vnodes           => false,
  :seeds            => [],
  :concurrent_reads => 32,
  :concurrent_writes => 32,
  :index_interval   => 128,
  :snitch           => 'SimpleSnitch',
  :package_name     => 'dsc12',
  :snitch_conf      => false,
  :enable_assertions => true,
  :jmx_server_hostname => false,
  :auto_bootstrap => true,
}

default[:cassandra][:jna] = {
    :base_url => "https://github.com/twall/jna/raw/4.0/dist",
    :jar_name => "jna.jar",
    :sha256sum => "dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19"
}

default[:cassandra][:tarball] = {
  :url => "auto",
  :md5 => "4c7c7620056ed436cd4d3c0756d02761"
}

default[:cassandra][:opscenter][:server] = {
  :package_name => "opscenter-free",
  :port => "8888",
  :interface => "0.0.0.0"
}

default[:cassandra][:opscenter][:agent] = {
  :download_url => nil,
  :checksum => nil,
  :install_dir => "/opt",
  :install_folder_name => "opscenter_agent",
  :binary_name => "opscenter-agent",
  :server_host => nil, # if nil, will use search to get IP by server role
  :server_role => "opscenter_server",
  :use_ssl => true
}
