default[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :version => '2.0.6',
  :service_name => 'cassandra',
  :user => "cassandra",
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
  :data_root_dir    => "/var/lib/cassandra/", # data/ subdir added to this root
  :commitlog_dir    => "/var/lib/cassandra/", # commitlog/ subdir added to this root
  :log_dir          => "/var/log/cassandra/",
  :hinted_handoff_enabled               => true,
  :max_hint_window_in_ms                => 10800000, # 3 hours
  :hinted_handoff_throttle_in_kb        => 1024,
  :max_hints_delivery_threads           => 2,
  :authenticator                        => "org.apache.cassandra.auth.AllowAllAuthenticator",
  :authorizer                           => "org.apache.cassandra.auth.AllowAllAuthorizer",
  :permissions_validity_in_ms           => 2000,
  :partitioner                          => "org.apache.cassandra.dht.Murmur3Partitioner",
  :disk_failure_policy                  => "stop", # stop,best_effort,ignore
  :key_cache_size_in_mb                 => "", # empty str for auto = (min(5% of Heap (in MB), 100MB))
  :key_cache_save_period                => 14400, # in seconds
  :row_cache_size_in_mb                 => 0,
  :row_cache_save_period                => 0, # in seconds
  :row_cache_provider                   => 'SerializingCacheProvider',
  :commitlog_sync                       => 'periodic', # 'batch' or 'periodic'
  :commitlog_sync_batch_window_in_ms    => 50, # only applies to 'batch' sync
  :commitlog_sync_period_in_ms          => 10000, # only applies to 'periodic' sync
  :commitlog_segment_size_in_mb         => 32,
  :concurrent_reads                     => 32, # suggested at 16 * number of drives
  :concurrent_writes                    => 32, # suggested at 8 * number of cpu cores
  :memtable_flush_queue_size            => 4,
  :trickle_fsync                        => false,
  :trickle_fsync_interval_in_kb         => 10240,
  :storage_port                         => 7000,
  :ssl_storage_port                     => 7001,
  :listen_address                       => node[:ipaddress],
  :broadcast_address                    => node[:ipaddress],
  :start_native_transport               => true,
  :native_transport_port                => "9042",
  :start_rpc                            => true,
  :rpc_address                          => node[:ipaddress],
  :rpc_port                             => "9160",
  :rpc_keepalive                        => true,
  :rpc_server_type                      => 'sync', # 'sync' or 'hsha', 
  :thrift_framed_transport_size_in_mb   => 15,
  :thrift_max_message_length_in_mb      => 16,
  :incremental_backups                  => false,
  :snapshot_before_compaction           => false,
  :auto_snapshot                        => true,
  :column_index_size_in_kb              => 64,
  :in_memory_compaction_limit_in_mb     => 64,
  :multithreaded_compaction             => false,
  :compaction_throughput_mb_per_sec     => 16,
  :compaction_preheat_key_cache         => true,
  :read_request_timeout_in_ms           => 10000,
  :range_request_timeout_in_ms          => 10000,
  :write_request_timeout_in_ms          => 10000,
  :truncate_request_timeout_in_ms       => 60000,
  :request_timeout_in_ms                => 10000,
  :cross_node_timeout                   => false,
  :streaming_socket_timeout_in_ms       => 0, #never timeout streams
  :snitch                               => 'SimpleSnitch',  # endpoint_snitch config
  :dynamic_snitch_update_interval_in_ms => 100,
  :dynamic_snitch_reset_interval_in_ms  => 600000,
  :dynamic_snitch_badness_threshold     => 0.1,
  :request_scheduler                    => 'org.apache.cassandra.scheduler.NoScheduler',
  :index_interval   => 128,
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :xss              => "256k",
  :vnodes           => false,
  :seeds            => [node[:ipaddress]],
  :package_name     => 'dsc20',
  :release          => '1',
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
  :md5 => "c8da1f4f546ea31ab85cfb236374863b"
}

default[:cassandra][:opscenter][:server] = {
  :package_name => "opscenter-free",
  :port => "8888",
  :interface => "0.0.0.0"
}

default[:cassandra][:opscenter][:agent] = {
  :package_name => "datastax-agent",
  :download_url => nil,
  :checksum => nil,
  :install_dir => "/opt",
  :install_folder_name => "opscenter_agent",
  :binary_name => "opscenter-agent",
  :server_host => nil, # if nil, will use search to get IP by server role
  :server_role => "opscenter_server",
  :use_ssl => true
}
