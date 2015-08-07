default['java']['jdk_version'] = '7'
default['java']['install_flavor'] = 'oracle'
default['java']['set_default'] = true
default['java']['oracle']['accept_oracle_download_terms'] = true

default['cassandra']['install_method'] = 'datastax'
default['cassandra']['install_java'] = true
default['cassandra']['cluster_name'] = nil
default['cassandra']['notify_restart'] = false
default['cassandra']['setup_jamm'] = false
default['cassandra']['initial_token'] = ''
default['cassandra']['service_name'] = 'cassandra'
default['cassandra']['user'] = 'cassandra'
default['cassandra']['group'] = 'cassandra'
default['cassandra']['setup_user'] = true
default['cassandra']['user_home'] = nil
default['cassandra']['system_user'] = true
default['cassandra']['version'] = '2.1.7'
default['cassandra']['pid_dir'] = '/var/run/cassandra'
default['cassandra']['dir_mode'] = '0755'
default['cassandra']['service_action'] = [:enable, :start]
default['cassandra']['jmx_port'] = 7199

default['cassandra']['limits']['memlock'] = 'unlimited'
default['cassandra']['limits']['nofile'] = 48_000
default['cassandra']['limits']['nproc'] = 'unlimited'

default['cassandra']['templates_cookbook'] = 'cassandra-dse'

default['cassandra']['root_dir'] = '/var/lib/cassandra' # data/ subdir added to this root
default['cassandra']['log_dir'] = '/var/log/cassandra'
default['cassandra']['rootlogger'] = 'INFO,stdout,R'

# Seed node discovery
default['cassandra']['seeds'] = node['ipaddress']

default['cassandra']['seed_discovery']['use_chef_search'] = false
default['cassandra']['seed_discovery']['count'] = 3
default['cassandra']['seed_discovery']['search_role'] = 'cassandra-seed'
default['cassandra']['seed_discovery']['search_query'] = nil

default['cassandra']['jbod']['slices'] = nil
default['cassandra']['jbod']['dir_name_prefix'] = 'data'

default['cassandra']['logback']['file']['max_file_size'] = '20MB'
default['cassandra']['logback']['file']['max_index'] = 20
default['cassandra']['logback']['file']['min_index'] = 1
default['cassandra']['logback']['file']['pattern'] = '%-5level [%thread] %date{ISO8601} %F:%L - %msg%n'

default['cassandra']['logback']['stdout']['enable'] = true
default['cassandra']['logback']['stdout']['pattern'] = '%-5level %date{HH:mm:ss,SSS} %msg%n'

default['cassandra']['log4j'] = {}

default['cassandra']['auto_bootstrap'] = true
default['cassandra']['hinted_handoff_enabled'] = true
default['cassandra']['max_hint_window_in_ms'] = 10_800_000 # 3 hours
default['cassandra']['hinted_handoff_throttle_in_kb'] = 1024
default['cassandra']['max_hints_delivery_threads'] = 2
default['cassandra']['permissions_validity_in_ms'] = 2000

default['cassandra']['authenticator'] = 'org.apache.cassandra.auth.AllowAllAuthenticator'
default['cassandra']['authorizer'] = 'org.apache.cassandra.auth.AllowAllAuthorizer'

default['cassandra']['partitioner'] = 'org.apache.cassandra.dht.Murmur3Partitioner'

default['cassandra']['disk_failure_policy'] = 'stop' # options: stop,best_effort,ignore

default['cassandra']['key_cache_size_in_mb'] = '' # empty str for auto = (min(5% of Heap (in MB), 100MB))
default['cassandra']['key_cache_save_period'] = 14_400 # in seconds
default['cassandra']['row_cache_size_in_mb'] = 0
default['cassandra']['row_cache_save_period'] = 0 # in seconds
default['cassandra']['row_cache_provider'] = 'SerializingCacheProvider'

default['cassandra']['commitlog_sync'] = 'periodic' # 'batch' or 'periodic'
default['cassandra']['commitlog_sync_batch_window_in_ms'] = 50 # only applies to 'batch' sync
default['cassandra']['commitlog_sync_period_in_ms'] = 10_000 # only applies to 'periodic' sync
default['cassandra']['commitlog_segment_size_in_mb'] = 32

default['cassandra']['concurrent_reads'] = 32 # suggested at 16 * number of drives
default['cassandra']['concurrent_writes'] = 32 # suggested at 8 * number of cpu cores
default['cassandra']['memtable_flush_queue_size'] = 4

default['cassandra']['trickle_fsync'] = false
default['cassandra']['trickle_fsync_interval_in_kb'] = 10_240

default['cassandra']['listen_address'] = node['ipaddress']
default['cassandra']['broadcast_address'] = node['ipaddress']
default['cassandra']['rpc_address'] = '0.0.0.0'

default['cassandra']['rpc_port'] = '9160'
default['cassandra']['storage_port'] = 7000
default['cassandra']['ssl_storage_port'] = 7001

default['cassandra']['native_transport_port'] = '9042'
# these two seem to be rejected by 2.0.x. MK.
default['cassandra']['native_transport_min_threads'] = nil
default['cassandra']['native_transport_max_threads'] = nil
default['cassandra']['start_native_transport'] = true

default['cassandra']['start_rpc'] = true
default['cassandra']['rpc_keepalive'] = true
default['cassandra']['rpc_server_type'] = 'sync' # 'sync' or 'hsha'
default['cassandra']['rpc_min_threads'] = 16
default['cassandra']['rpc_max_threads'] = 2048

default['cassandra']['thrift_framed_transport_size_in_mb'] = 15
default['cassandra']['thrift_max_message_length_in_mb'] = 16
default['cassandra']['incremental_backups'] = false
default['cassandra']['snapshot_before_compaction'] = false
default['cassandra']['auto_snapshot'] = true
default['cassandra']['column_index_size_in_kb'] = 64
default['cassandra']['in_memory_compaction_limit_in_mb'] = 64
default['cassandra']['concurrent_compactors'] = nil
default['cassandra']['multithreaded_compaction'] = false
default['cassandra']['compaction_throughput_mb_per_sec'] = 16
default['cassandra']['compaction_preheat_key_cache'] = true

default['cassandra']['read_request_timeout_in_ms'] = 10_000
default['cassandra']['range_request_timeout_in_ms'] = 10_000
default['cassandra']['write_request_timeout_in_ms'] = 10_000
default['cassandra']['truncate_request_timeout_in_ms'] = 60_000
default['cassandra']['request_timeout_in_ms'] = 10_000
default['cassandra']['cross_node_timeout'] = false
default['cassandra']['streaming_socket_timeout_in_ms'] = 0 # never timeout streams
default['cassandra']['stream_throughput_outbound_megabits_per_sec'] = 400

default['cassandra']['snitch'] = 'SimpleSnitch'  # endpoint_snitch config
default['cassandra']['dynamic_snitch_update_interval_in_ms'] = 100
default['cassandra']['dynamic_snitch_reset_interval_in_ms'] = 600_000
default['cassandra']['dynamic_snitch_badness_threshold'] = 0.1
default['cassandra']['request_scheduler'] = 'org.apache.cassandra.scheduler.NoScheduler'
default['cassandra']['phi_convict_threshold'] = 8
default['cassandra']['index_interval'] = 128
default['cassandra']['max_heap_size'] = nil
default['cassandra']['heap_new_size'] = nil
default['cassandra']['xss'] = '256k'
default['cassandra']['vnodes'] = true
default['cassandra']['num_tokens'] = 256
default['cassandra']['enable_assertions'] = true
default['cassandra']['internode_compression'] = 'all' # all, dc, none
default['cassandra']['jmx_server_hostname'] = false
default['cassandra']['metrics_reporter']['enabled'] = false
default['cassandra']['metrics_reporter']['name'] = 'metrics-graphite'
default['cassandra']['metrics_reporter']['jar_url'] = 'http://search.maven.org/remotecontent?filepath=com/yammer/metrics/metrics-graphite/2.2.0/metrics-graphite-2.2.0.jar'
default['cassandra']['metrics_reporter']['sha256sum'] = '6b4042aabf532229f8678b8dcd34e2215d94a683270898c162175b1b13d87de4'
default['cassandra']['metrics_reporter']['jar_name'] = 'metrics-graphite-2.2.0.jar'
default['cassandra']['metrics_reporter']['config'] = {} # should be a hash of relevant config

# Heap Dump
default['cassandra']['heap_dump'] = true
default['cassandra']['heap_dump_dir'] = nil

# GC tuning options
default['cassandra']['gc_survivor_ratio'] = 8
default['cassandra']['gc_max_tenuring_threshold'] = 1
default['cassandra']['gc_cms_initiating_occupancy_fraction'] = 75

# C* 2.1.0
default['cassandra']['broadcast_rpc_address'] = node['ipaddress']
default['cassandra']['tombstone_failure_threshold'] = 100_000
default['cassandra']['tombstone_warn_threshold'] = 1000
default['cassandra']['sstable_preemptive_open_interval_in_mb'] = 50
default['cassandra']['memtable_allocation_type'] = 'heap_buffers'
default['cassandra']['index_summary_capacity_in_mb'] = ''
default['cassandra']['index_summary_resize_interval_in_minutes'] = 60
default['cassandra']['concurrent_counter_writes'] = 32
default['cassandra']['counter_cache_save_period'] = 7200
default['cassandra']['counter_cache_size_in_mb'] = ''
default['cassandra']['counter_write_request_timeout_in_ms'] = 5000
default['cassandra']['commit_failure_policy'] = 'stop'
default['cassandra']['cas_contention_timeout_in_ms'] = 1000
default['cassandra']['batch_size_warn_threshold_in_kb'] = 5
default['cassandra']['batchlog_replay_throttle_in_kb'] = 1024

default['cassandra']['encryption']['server']['internode_encryption'] = 'none' # none, all, dc, rack
default['cassandra']['encryption']['server']['keystore'] = 'conf/.keystore'
default['cassandra']['encryption']['server']['keystore_password'] = 'cassandra'
default['cassandra']['encryption']['server']['truststore'] = 'conf/.truststore'
default['cassandra']['encryption']['server']['truststore_password'] = 'cassandra'
# More advanced option defaults... (matching the default file comments)
# Default values provided but not actually installed in the config so the
# defaults can change with versions in the expected, unmanaged way.
default['cassandra']['encryption']['server']['enable_advanced'] = false
default['cassandra']['encryption']['server']['protocol'] = 'TLS'
default['cassandra']['encryption']['server']['algorithm'] = 'SunX509'
default['cassandra']['encryption']['server']['store_type'] = 'JKS'
default['cassandra']['encryption']['server']['cipher_suites'] = '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]'
default['cassandra']['encryption']['server']['require_client_auth'] = false

default['cassandra']['encryption']['client']['enabled'] = false
default['cassandra']['encryption']['client']['keystore'] = 'conf/.keystore'
default['cassandra']['encryption']['client']['keystore_password'] = 'cassandra'
default['cassandra']['encryption']['client']['require_client_auth'] = false
# trust store only configured if require_client_auth is true.
default['cassandra']['encryption']['client']['truststore'] = 'conf/.truststore'
default['cassandra']['encryption']['client']['truststore_password'] = 'cassandra'
# More advanced option defaults... (matching the default file comments)
# Default values provided but not actually installed in the config so the
# defaults can change with versions in the expected, unmanaged way.
default['cassandra']['encryption']['client']['enable_advanced'] = false
default['cassandra']['encryption']['client']['protocol'] = 'TLS'
default['cassandra']['encryption']['client']['algorithm'] = 'SunX509'
default['cassandra']['encryption']['client']['store_type'] = 'JKS'
default['cassandra']['encryption']['client']['cipher_suites'] = '[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA]'
default['cassandra']['encryption']['client']['require_client_auth'] = false

default['cassandra']['jna']['base_url'] = 'https://github.com/twall/jna/raw/4.0/dist'
default['cassandra']['jna']['jar_name'] = 'jna.jar'
default['cassandra']['jna']['sha256sum'] = 'dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19'

default['cassandra']['tarball']['url'] = 'auto'
default['cassandra']['tarball']['md5'] = '9d6fd1fb9cf4836ef168796fed8f1282'

default['cassandra']['opscenter']['version'] = nil
default['cassandra']['opscenter']['server']['package_name'] = 'opscenter'
default['cassandra']['opscenter']['server']['port'] = '8888'
default['cassandra']['opscenter']['server']['interface'] = '0.0.0.0'
default['cassandra']['opscenter']['server']['authentication'] = false

default['cassandra']['opscenter']['agent']['package_name'] = 'datastax-agent'
default['cassandra']['opscenter']['agent']['download_url'] = nil
default['cassandra']['opscenter']['agent']['checksum'] = nil
default['cassandra']['opscenter']['agent']['install_dir'] = '/opt'
default['cassandra']['opscenter']['agent']['install_folder_name'] = 'opscenter_agent'
default['cassandra']['opscenter']['agent']['binary_name'] = 'opscenter-agent'
default['cassandra']['opscenter']['agent']['server_host'] = nil # if nil, will use search to get IP by server role
default['cassandra']['opscenter']['agent']['use_chef_search'] = true
default['cassandra']['opscenter']['agent']['server_role'] = 'opscenter_server'
default['cassandra']['opscenter']['agent']['use_ssl'] = true
default['cassandra']['opscenter']['agent']['conf_dir'] = '/var/lib/datastax-agent/conf'
