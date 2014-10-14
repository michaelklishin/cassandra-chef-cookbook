

default[:java][:jdk_version] = '7'
default[:java][:install_flavor] = 'oracle'
default[:java][:set_default] = true
default[:java][:oracle][:accept_oracle_download_terms] = true
default[:java][:arch] = node[:kernel][:machine]

default[:cassandra] = {
  :install_java   => true,
  :cluster_name   => nil,
  :notify_restart => false,
  :setup_jna      => true,
  :setup_jamm     => false,
  :initial_token  => "",
  :service_name   => 'cassandra',
  :user           => "cassandra",
  :group          => "cassandra",
  :setup_user     => true,
  :user_home      => nil,
  :pid_dir        => "/var/run/cassandra",
  :dir_mode       => '0755',
  :service_action => [:enable, :start],

  :limits => {
    :memlock  => 'unlimited',
    :nofile   => 48000,
    :nproc    => 'unlimited'
  },

  :templates_cookbook => "cassandra",

  :root_dir   => "/var/lib/cassandra", # data/ subdir added to this root
  :log_dir    => "/var/log/cassandra",
  :rootlogger => "INFO,stdout,R",

  :logback    => {
    :file     => {
      :max_file_size    => '20MB',
      :max_index        => 20,
      :min_index        => 1,
      :pattern          => '%-5level [%thread] %date{ISO8601} %F:%L - %msg%n'
    },
    :stdout   => {
      :enable   => true,
      :pattern  => '%-5level %date{HH:mm:ss,SSS} %msg%n'
    }
  },

  :log4j => {},

  :auto_bootstrap => true,
  :hinted_handoff_enabled               => true,
  :max_hint_window_in_ms                => 10800000, # 3 hours
  :hinted_handoff_throttle_in_kb        => 1024,
  :max_hints_delivery_threads           => 2,
  :permissions_validity_in_ms           => 2000,

  :authenticator                        => "org.apache.cassandra.auth.AllowAllAuthenticator",
  :authorizer                           => "org.apache.cassandra.auth.AllowAllAuthorizer",

  :partitioner                          => "org.apache.cassandra.dht.Murmur3Partitioner",

  :disk_failure_policy                  => "stop", # options: stop,best_effort,ignore

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

  :listen_address                       => node[:ipaddress],
  :broadcast_address                    => node[:ipaddress],
  :rpc_address                          => "0.0.0.0",

  :rpc_port                             => "9160",
  :storage_port                         => 7000,
  :ssl_storage_port                     => 7001,
  :native_transport_port                => "9042",

  :start_native_transport               => true,
  :start_rpc                            => true,
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
  :stream_throughput_outbound_megabits_per_sec => 400,

  :snitch                               => 'SimpleSnitch',  # endpoint_snitch config
  :dynamic_snitch_update_interval_in_ms => 100,
  :dynamic_snitch_reset_interval_in_ms  => 600000,
  :dynamic_snitch_badness_threshold     => 0.1,
  :request_scheduler                    => 'org.apache.cassandra.scheduler.NoScheduler',
  :phi_convict_threshold                => 8,
  :index_interval   => 128,
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :xss              => "256k",
  :vnodes           => false,
  :seeds            => [node[:ipaddress]],
  :snitch_conf      => false,
  :enable_assertions => true,
  :internode_compression => 'all', # all, dc, none
  :jmx_server_hostname => false,

  # C* 2.1.0
  :broadcast_rpc_address          => node[:ipaddress],
  :tombstone_failure_threshold    => 100000,
  :tombstone_warn_threshold       => 1000,
  :sstable_preemptive_open_interval_in_mb   => 50,
  :memtable_allocation_type       => 'heap_buffers',
  :index_summary_capacity_in_mb   => '',
  :index_summary_resize_interval_in_minutes => 60,
  :concurrent_counter_writes      => 32,
  :counter_cache_save_period      => 7200,
  :counter_cache_size_in_mb       => '',
  :counter_write_request_timeout_in_ms      => 5000,
  :commit_failure_policy          => 'stop',
  :cas_contention_timeout_in_ms   => 1000,
  :batch_size_warn_threshold_in_kb          => 5,
  :batchlog_replay_throttle_in_kb => 1024


}

default[:cassandra][:encryption][:server] = {
  :internode_encryption  => 'none', # none, all, dc, rack
  :keystore              => 'conf/.keystore',
  :keystore_password     => 'cassandra',
  :truststore            => 'conf/.truststore',
  :truststore_password   => 'cassandra',
  # More advanced option defaults... (matching the default file comments)
  # Default values provided but not actually installed in the config so the
  # defaults can change with versions in the expected, unmanaged way.
  :enable_advanced       => false,
  :protocol              => 'TLS',
  :algorithm             => 'SunX509',
  :store_type            => 'JKS',
  :cipher_suites         => '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]',
  :require_client_auth   => false
}


default[:cassandra][:encryption][:client] = {
  :enabled               => false,
  :keystore              => 'conf/.keystore',
  :keystore_password     => 'cassandra',
  :require_client_auth   => false,
  # trust store only configured if require_client_auth is true.
  :truststore            => 'conf/.truststore',
  :truststore_password   => 'cassandra',
  # More advanced option defaults... (matching the default file comments)
  # Default values provided but not actually installed in the config so the
  # defaults can change with versions in the expected, unmanaged way.
  :enable_advanced       => false,
  :protocol              => 'TLS',
  :algorithm             => 'SunX509',
  :store_type            => 'JKS',
  :cipher_suites         => '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]',
  :require_client_auth   => false
}

default[:cassandra][:jna] = {
    :base_url => "https://github.com/twall/jna/raw/4.0/dist",
    :jar_name => "jna.jar",
    :sha256sum => "dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19"
}

default[:cassandra][:jamm] = {
    :base_url => "http://repo1.maven.org/maven2/com/github/stephenc/jamm/#{node.attribute[:cassandra][:jamm_version]}",
    :jar_name => "jamm-#{node.attribute[:cassandra][:jamm_version]}.jar",
    :sha256sum => "0422d3543c01df2f1d8bd1f3064adb54fb9e93f3"
}

default[:cassandra][:tarball] = {
  :url => "auto",
  :md5 => "9d6fd1fb9cf4836ef168796fed8f1282"
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
