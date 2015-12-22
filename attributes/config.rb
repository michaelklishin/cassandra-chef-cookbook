default['cassandra']['config']['cluster_name'] = nil
default['cassandra']['config']['auto_bootstrap'] = true
default['cassandra']['config']['hinted_handoff_enabled'] = true
default['cassandra']['config']['max_hint_window_in_ms'] = 10_800_000 # 3 hours
default['cassandra']['config']['hinted_handoff_throttle_in_kb'] = 1024
default['cassandra']['config']['max_hints_delivery_threads'] = 2
default['cassandra']['config']['permissions_validity_in_ms'] = 2000
default['cassandra']['config']['authenticator'] = 'org.apache.cassandra.auth.AllowAllAuthenticator'
default['cassandra']['config']['authorizer'] = 'org.apache.cassandra.auth.AllowAllAuthorizer'
default['cassandra']['config']['partitioner'] = 'org.apache.cassandra.dht.Murmur3Partitioner'
default['cassandra']['config']['disk_failure_policy'] = 'stop' # options: stop,best_effort,ignore
default['cassandra']['config']['key_cache_size_in_mb'] = nil # empty str for auto = (min(5% of Heap (in MB), 100MB))
default['cassandra']['config']['key_cache_save_period'] = 14_400 # in seconds
default['cassandra']['config']['key_cache_keys_to_save'] = nil # 100
default['cassandra']['config']['row_cache_size_in_mb'] = 0
default['cassandra']['config']['row_cache_save_period'] = 0 # in seconds
default['cassandra']['config']['row_cache_keys_to_save'] = nil # 100
default['cassandra']['config']['row_cache_provider'] = 'SerializingCacheProvider'
default['cassandra']['config']['commitlog_sync'] = 'periodic' # 'batch' or 'periodic'
default['cassandra']['config']['commitlog_sync_batch_window_in_ms'] = 50 # only applies to 'batch' sync
default['cassandra']['config']['commitlog_sync_period_in_ms'] = 10_000 # only applies to 'periodic' sync
default['cassandra']['config']['commitlog_segment_size_in_mb'] = 32
default['cassandra']['config']['commitlog_total_space_in_mb'] = 4096
default['cassandra']['config']['concurrent_reads'] = 32 # suggested at 16 * number of drives
default['cassandra']['config']['concurrent_writes'] = 32 # suggested at 8 * number of cpu cores
default['cassandra']['config']['trickle_fsync'] = false
default['cassandra']['config']['trickle_fsync_interval_in_kb'] = 10_240
default['cassandra']['config']['listen_address'] = node['ipaddress']
default['cassandra']['config']['broadcast_address'] = node['ipaddress']
default['cassandra']['config']['rpc_address'] = '0.0.0.0'
default['cassandra']['config']['rpc_port'] = '9160'
default['cassandra']['config']['storage_port'] = 7000
default['cassandra']['config']['ssl_storage_port'] = 7001
default['cassandra']['config']['native_transport_port'] = '9042'

if node['cassandra']['version'] < '2.0'
  default['cassandra']['config']['memtable_flush_queue_size'] = 4
  default['cassandra']['config']['in_memory_compaction_limit_in_mb'] = 64
  default['cassandra']['config']['concurrent_compactors'] = nil
  default['cassandra']['config']['multithreaded_compaction'] = false
  default['cassandra']['config']['compaction_preheat_key_cache'] = true
  default['cassandra']['config']['native_transport_min_threads'] = nil
  default['cassandra']['config']['native_transport_max_threads'] = nil
end

default['cassandra']['config']['start_native_transport'] = true
default['cassandra']['config']['start_rpc'] = true
default['cassandra']['config']['rpc_keepalive'] = true
default['cassandra']['config']['rpc_server_type'] = 'sync' # 'sync' or 'hsha'
default['cassandra']['config']['rpc_min_threads'] = 16
default['cassandra']['config']['rpc_max_threads'] = 2048
default['cassandra']['config']['thrift_framed_transport_size_in_mb'] = 15
default['cassandra']['config']['thrift_max_message_length_in_mb'] = 16
default['cassandra']['config']['incremental_backups'] = false
default['cassandra']['config']['snapshot_before_compaction'] = false
default['cassandra']['config']['auto_snapshot'] = true
default['cassandra']['config']['column_index_size_in_kb'] = 64
default['cassandra']['config']['compaction_throughput_mb_per_sec'] = 16
default['cassandra']['config']['read_request_timeout_in_ms'] = 10_000
default['cassandra']['config']['range_request_timeout_in_ms'] = 10_000
default['cassandra']['config']['write_request_timeout_in_ms'] = 10_000
default['cassandra']['config']['truncate_request_timeout_in_ms'] = 60_000
default['cassandra']['config']['request_timeout_in_ms'] = 10_000
default['cassandra']['config']['cross_node_timeout'] = false
default['cassandra']['config']['streaming_socket_timeout_in_ms'] = 0 # never timeout streams
default['cassandra']['config']['stream_throughput_outbound_megabits_per_sec'] = 400
default['cassandra']['config']['endpoint_snitch'] = 'SimpleSnitch' # endpoint_snitch config
default['cassandra']['config']['dynamic_snitch_update_interval_in_ms'] = 100
default['cassandra']['config']['dynamic_snitch_reset_interval_in_ms'] = 600_000
default['cassandra']['config']['dynamic_snitch_badness_threshold'] = 0.1
default['cassandra']['config']['request_scheduler'] = 'org.apache.cassandra.scheduler.NoScheduler'
default['cassandra']['config']['phi_convict_threshold'] = 8
default['cassandra']['config']['index_interval'] = 128
default['cassandra']['config']['num_tokens'] = 256
default['cassandra']['config']['internode_compression'] = 'all' # all, dc, none
default['cassandra']['config']['inter_dc_tcp_nodelay'] = true

# C* 2.1.0
if node['cassandra']['version'] >= '2.1'
  default['cassandra']['config']['broadcast_rpc_address'] = node['ipaddress']
  default['cassandra']['config']['tombstone_failure_threshold'] = 100_000
  default['cassandra']['config']['tombstone_warn_threshold'] = 1000
  default['cassandra']['config']['sstable_preemptive_open_interval_in_mb'] = 50
  default['cassandra']['config']['memtable_allocation_type'] = 'heap_buffers'
  default['cassandra']['config']['index_summary_capacity_in_mb'] = nil
  default['cassandra']['config']['index_summary_resize_interval_in_minutes'] = 60
  default['cassandra']['config']['concurrent_counter_writes'] = 32
  default['cassandra']['config']['counter_cache_save_period'] = 7200
  default['cassandra']['config']['counter_cache_size_in_mb'] = nil
  default['cassandra']['config']['counter_write_request_timeout_in_ms'] = 5000
  default['cassandra']['config']['commit_failure_policy'] = 'stop'
  default['cassandra']['config']['cas_contention_timeout_in_ms'] = 1000
  default['cassandra']['config']['batch_size_warn_threshold_in_kb'] = 5
  default['cassandra']['config']['batchlog_replay_throttle_in_kb'] = 1024
end

# C* server encryption configuration options
default['cassandra']['config']['server_encryption_options']['internode_encryption'] = 'none' # none, all, dc, rack
default['cassandra']['config']['server_encryption_options']['keystore'] = 'conf/.keystore'
default['cassandra']['config']['server_encryption_options']['keystore_password'] = 'cassandra'
default['cassandra']['config']['server_encryption_options']['truststore'] = 'conf/.truststore'
default['cassandra']['config']['server_encryption_options']['truststore_password'] = 'cassandra'

# More advanced option defaults... (matching the default file comments)
# Default values provided but not actually installed in the config so the
# defaults can change with versions in the expected, unmanaged way.
default['cassandra']['config']['server_encryption_options']['enable_advanced'] = false

if node['cassandra']['config']['server_encryption_options']['enable_advanced']
  default['cassandra']['config']['server_encryption_options']['protocol'] = 'TLS'
  default['cassandra']['config']['server_encryption_options']['algorithm'] = 'SunX509'
  default['cassandra']['config']['server_encryption_options']['store_type'] = 'JKS'
  default['cassandra']['config']['server_encryption_options']['cipher_suites'] = '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]'
  default['cassandra']['config']['server_encryption_options']['require_client_auth'] = false
end

# C* client encryption configuration options
default['cassandra']['config']['client_encryption_options']['enabled'] = false
default['cassandra']['config']['client_encryption_options']['keystore'] = 'conf/.keystore'
default['cassandra']['config']['client_encryption_options']['keystore_password'] = 'cassandra'
default['cassandra']['config']['client_encryption_options']['require_client_auth'] = false

if node['cassandra']['config']['client_encryption_options']['require_client_auth']
  # trust store only configured if require_client_auth is true.
  default['cassandra']['config']['client_encryption_options']['truststore'] = 'conf/.truststore'
  default['cassandra']['config']['client_encryption_options']['truststore_password'] = 'cassandra'
end

# More advanced option defaults... (matching the default file comments)
# Default values provided but not actually installed in the config so the
# defaults can change with versions in the expected, unmanaged way.
default['cassandra']['config']['client_encryption_options']['enable_advanced'] = false

if node['cassandra']['config']['client_encryption_options']['enable_advanced']
  default['cassandra']['config']['client_encryption_options']['protocol'] = 'TLS'
  default['cassandra']['config']['client_encryption_options']['algorithm'] = 'SunX509'
  default['cassandra']['config']['client_encryption_options']['store_type'] = 'JKS'
  default['cassandra']['config']['client_encryption_options']['cipher_suites'] = '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]'
end
