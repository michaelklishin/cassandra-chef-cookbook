# Apache Cassandra Chef Cookbook

[![Build Status](https://travis-ci.org/michaelklishin/cassandra-chef-cookbook.svg?branch=master)](https://travis-ci.org/michaelklishin/cassandra-chef-cookbook)

This is a Chef cookbook for Apache Cassandra ([DataStax
Community Edition](http://www.datastax.com/products/community)) as
well as DataStax Enterprise.

It uses officially released packages and provides an Upstart service
script. It has fairly complete support for adjustment of Cassandra
configuration parameters using Chef node attributes.

It was originally created for CI and development environments and now supports cluster discovery using Chef search. **Feel free to contribute** what you find missing!


## Cookbook Dependencies

- java
- ulimit
- apt
- yum, '~> 3.0'
- ark


## Cassandra Dependencies

OracleJDK 8, OpenJDK 8, OracleJDK 7, OpenJDK 7, OpenJDK 6 or Sun JDK 6.


## Berkshelf

### Most Recent Release

``` ruby
cookbook 'cassandra-dse', '~> 3.5.0'
```

### From Git

``` ruby
cookbook 'cassandra-dse', github: 'michaelklishin/cassandra-chef-cookbook'
```


## Supported Apache Cassandra Version

This cookbook currently provides

 * Cassandra 2.x via tarball
 * Cassandra 2.x (DataStax Community Edition) via packages.
 * DataStax Enterprise (DSE)

## Supported OS Distributions

 * Ubuntu 11.04 through 14.04 via DataStax apt repo.
 * RHEL/CentOS via DataStax yum repo.
 * RHEL/CentOS/Amazon via tarball

## Support JDK Versions

Cassandra 2.x requires JDK 7+, Oracle JDK is recommended.

## Recipes

The main recipe is `cassandra-dse::default` which together with the `node[:cassandra][:install_method]` attribute will be responsible for including the proper installation recipe and recipe `cassandra-dse::config` for configuring both `datastax` and `tarball` C* installation.

Two actual installation recipes are `cassandra-dse::tarball` and `cassandra-dse::datastax`. The former uses official tarball
and thus can be used to provision any specific version.

The latter uses DataStax repository via packages. You can install different versions (ex. `dsc20` for v2.0) available in the repository by altering `:package_name` attribute (`dsc20` by default).

Recently we have moved all the configuration resources to a separate recipe `cassandra-des::config`, which means recipes `cassandra-dse::tarball` and `cassandra-dse::datastax` are only responsible for C* installation.

>> Users with cookbook version `=<3.5.0` needs to update the `run_list`, in case of not using `cassandra-dse::default` recipe.

include_recipe `cassandra-dse` uses `cassandra-dse::datastax` as the default.

### DataStax Enterprise

You can also install the DataStax Enterprise edition by adding `node[:cassandra][:dse]` attributes according to the datastax.rb.
 * `node[:cassandra][:package_name]`: Override default value to 'dse-full'.
 * `node[:cassandra][:service_name]`: Override default value to 'dse'.

Unencrypted Credentials:
 * `node[:cassandra][:dse][:credentials][:username]`: Your username from Datastax website.
 * `node[:cassandra][:dse][:credentials][:password]`: Your password from Datastax website.

Encrypted Credentials:
 * `node[:cassandra][:dse][:credentials][:databag][:name]`: Databag name, i.e. the value 'cassandra' will reference to `/data_bags/cassandra`.
 * `node[:cassandra][:dse][:credentials][:databag][:item]`: Databag item, i.e. the value 'main' will reference to `/data_bags/cassandra/main.json`.
 * `node[:cassandra][:dse][:credentials][:databag][:entry]`: The field name in the databag item, in which the credetials are written. i.e. the data_bag:
```
{
  "id": "main",
  "entry": {
    "username": "%USERNAME%",
    "password": "%PASSWORD%"
  }
}
```

There are also recipes for DataStax opscenter installation (
`cassandra-dse::opscenter_agent_tarball`,
`cassandra-dse::opscenter_agent_datastax`, and
`cassandra-dse::opscenter_server` ) along with attributes available
for override (see below).

### JNA Support (for C* Versions Prior to 2.1.0)

The `node[:cassandra][:setup_jna]` attribute will install the jna.jar in the
`/usr/share/java/jna.jar`, and create a symbolic link to it on
`#{cassandra.lib\_dir}/jna.jar`, according to the [DataStax
documentation](http://www.datastax.com/documentation/cassandra/1.2/webhelp/cassandra/install/installJnaDeb.html).


## Node Attributes

### Core Attributes

 * `node[:cassandra][:install_method]` (default: datastax): The installation method to use (either 'datastax' or 'tarball').
 * `node[:cassandra][:cluster_name]` (default: none): Name of the cluster to create. This is required.
 * `node[:cassandra][:version]` (default: a recent patch version): version to provision
 * `node[:cassandra][:tarball][:url]` and `node[:cassandra][:tarball][:sha256sum]` specify tarball URL and SHA256 check sum used by the `cassandra::tarball` recipe.
  * Setting `node[:cassandra][:tarball][:url]` to "auto" (default) will download the tarball of the specified version from the Apache repository.
 * `node[:cassandra][:setup_user]` (default: true): create user/group for Cassandra node process
 * `node[:cassandra][:user]`: username Cassandra node process will use
 * `node[:cassandra][:group]`: groupname Cassandra node process will use
 * `node[:cassandra][:heap_new_size]` set JVM `-Xmn`; if nil, defaults to `min(100MB * num_cores, 1/4 * heap size)`
 * `node[:cassandra][:max_heap_size]` set JVM `-Xms` and `-Xmx`; if nil, defaults to `max(min(1/2 ram, 1024MB), min(1/4 ram, 8GB))`
 * `node[:cassandra][:installation_dir]` (default: `/usr/local/cassandra`): installation directory
 * `node[:cassandra][:root_dir]` (default: `/var/lib/cassandra`): data directory root
 * `node[:cassandra][:log_dir]` (default: `/var/log/cassandra`): log directory
 * `node[:cassandra][:local_jmx]` (default: true): bind JMX listener to localhost
 * `node[:cassandra][:jmx_port]` (default: 7199): port to listen for JMX
 * `node[:cassandra][:notify_restart]` (default: false): notify Cassandra service restart upon resource update
  * Setting `node[:cassandra][:notify_restart]` to true will restart Cassandra service upon resource change
 * `node[:cassandra][:setup_jna]` (default: true): installs jna.jar
 * `node[:cassandra][:skip_jna]` (default: false): (2.1.0 and up only) removes jna.jar, adding '-Dcassandra.boot_without_jna=true' for low-memory C* installations
 * `node[:cassandra][:pid_dir]` (default: true): pid directory for Cassandra node process for `cassandra::tarball` recipe
 * `node[:cassandra][:dir_mode]` (default: 0755): default permission set for Cassandra node directory / files
 * `node[:cassandra][:service_action]` (default: [:enable, :start]): default service actions for the service
 * `node[:cassandra][:install_java]` (default: true): whether to run the open source java cookbook
 * `node[:cassandra][:cassandra_old_version_20]` (default: ): attribute used in cookbook to determine C* version older or newer than 2.1
 * `node[:cassandra][:log_config_files]` (default: calculated): log framework configuration files name array
 * `node[:cassandra][:xss]`  JVM per thread stack-size (-Xss option) (default: 256k).
 * `node[:cassandra][:jmx_server_hostname]` java.rmi.server.hostname option for JMX interface, necessary to set when you have problems connecting to JMX) (default: false)
 * `node[:cassandra][:heap_dump]` -XX:+HeapDumpOnOutOfMemoryError JVM parameter (default: true)
 * `node[:cassandra][:heap_dump_dir]` Directory where heap dumps will be placed (default: nil, which will use cwd)
 * `node[:cassandra][:vnodes]` enable vnodes. (default: true)

 For the complete set of supported attributes, please consult [the source](https://github.com/michaelklishin/cassandra-chef-cookbook/tree/master/attributes).

Attributes used to define JBOD functionality

* `default['cassandra']['jbod']['slices']` - defines the number of jbod slices while each represents data directory. By default disables with nil.
* `default['cassandra']['jbod']['dir_name_prefix']` - defines the data directory prefix
For example if you want to connect 4 EBS disks as a JBOD slices the names will be in the following format: data1,data2,data3,data4
cassandra.yaml.erb will generate automatically entry per data_dir location
Please note: this functionality is not creating volumes or directories. It takes care of configuration. You can use same parameters with AWS cookbook to create EBS volumes and map to directories.

Attributes for fine tuning CMS/ParNew, the GC algorithm recommended for Cassandra deployments:

 * `node[:cassandra][:gc_survivor_ratio]` -XX:SurvivorRatio JVM parameter (default: 8)
 * `node[:cassandra][:gc_max_tenuring_threshold]` -XX:MaxTenuringThreshold JVM parameter (default: 1)
 * `node[:cassandra][:gc_cms_initiating_occupancy_fraction]` -XX:CMSInitiatingOccupancyFraction JVM parameter (default: 75)

Attributes for enabling G1 GC.

 * `node[:cassandra][:jvm][:g1]` (default: false)

Attributes for enabling GC detail/logging.

 * `node[:cassandra][:jvm][:gcdetail]` (default: false)

Descriptions for these JVM parameters can be found [here](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html#PerformanceTuning) and [here](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html#cms.starting_a_cycle).


### Seed Discovery Attributes

 * `node[:cassandra][:seeds]` (default: `[node[:ipaddress]]`): an array of nodes this node will contact to discover cluster topology
 * `node[:cassandra][:seed_discovery][:use_chef_search]` (default: false): enabled seed discovery using Chef search
 * `node[:cassandra][:seed_discovery][:search_role]` (default: `"cassandra-seed"`): role to use in search query
 * `node[:cassandra][:seed_discovery][:search_query]` (default: uses `node[:cassandra][:seed_discovery][:search_role]`): allows
   for overriding the entire Chef search query
 * `node[:cassandra][:seed_discovery][:count]` (default: `3`): how many nodes to include into seed list. First N nodes are
   taken in the order Chef search returns them. IP addresses of the nodes are sorted lexographically.

### cassandra.yaml Attributes

 * `node[:cassandra][:config][:num_tokens]` set the desired number of tokens. (default: 256)
 * `node[:cassandra][:config][:listen_address]` (default: node[:ipaddress]): address clients will use to connect to the node
 * `node[:cassandra][:config][:broadcast_address]` (default: node IP address): address to broadcast to other Cassandra nodes
 * `node[:cassandra][:config][:rpc_address]` (default: 0.0.0.0): address to bind the RPC interface
 * `node[:cassandra][:config][:hinted_handoff_enabled]` see http://wiki.apache.org/cassandra/HintedHandoff (default: true)
 * `node[:cassandra][:config][:max_hint_window_in_ms]` The maximum amount of time a dead host will have hints generated (default: 10800000).
 * `node[:cassandra][:config][:hinted_handoff_throttle_in_kb]` throttle in KB's per second, per delivery thread (default: 1024)
 * `node[:cassandra][:config][:max_hints_delivery_threads]` Number of threads with which to deliver hints (default: 2)
 * `node[:cassandra][:config][:authenticator]` Authentication backend (default: org.apache.cassandra.auth.AllowAllAuthenticator)
 * `node[:cassandra][:config][:authorizer]` Authorization backend (default: org.apache.cassandra.auth.AllowAllAuthorizer)
 * `node[:cassandra][:config][:permissions_validity_in_ms]` Validity period for permissions cache, set to0 to disable (default: 2000)
 * `node[:cassandra][:config][:partitioner]` The partitioner to distribute keys across the cluster (default: org.apache.cassandra.dht.Murmur3Partitioner).
 * `node[:cassandra][:config][:disk_failure_policy]` policy for data disk failures: stop, best\_effort, or ignore (default: stop)
 * `node[:cassandra][:config][:key_cache_size_in_mb]` Maximum size of the key cache in memory. Set to 0 to disable, or "" for auto = (min(5% of Heap (in MB), 100MB)) (default: "", auto).
 * `node[:cassandra][:config][:key_cache_save_period]` Duration in seconds after which key cache is saved to saved\_caches\_directory. (default: 14400)
 * `node[:cassandra][:config][:row_cache_size_in_mb]` Maximum size of the row cache in memory, 0 to disable (default: 0)
 * `node[:cassandra][:config][:row_cache_save_period]` Duration in seconds after which row cache is saved to saved\_caches\_directory, 0 to disable cache save. (default: 0)
 * `node[:cassandra][:config][:row_cache_provider]` The provider for the row cache to use (default: SerializingCacheProvider)
 * `node[:cassandra][:config][:commitlog_sync]` periodic to ack writes immediately with periodic fsyncs, or batch to wait until fsync to ack writes (default: periodic)
 * `node[:cassandra][:config][:commitlog_sync_period_in_ms]` period for commitlog fsync when commitlog\_sync = periodic (default: 10000)
 * `node[:cassandra][:config][:commitlog_sync_batch_window_in_ms]` batch window for fsync when commitlog\_sync = batch (default: 50)
 * `node[:cassandra][:config][:commitlog_segment_size_in_mb]` Size of individual commitlog file segments (default: 32)
 * `node[:cassandra][:config][:commitlog_total_space_in_mb]` If space gets above this value (it will round up to the next nearest segment multiple), Cassandra will flush every dirty CF in the oldest segment and remove it. (default: 4096)
 * `node[:cassandra][:config][:concurrent_reads]` Should be set to 16 * drives (default: 32)
 * `node[:cassandra][:config][:concurrent_writes]` Should be set to 8 * cpu cores (default: 32)
 * `node[:cassandra][:config][:trickle_fsync]` Enable this to avoid sudden dirty buffer flushing from impacting read latencies.  Almost always a good idea on SSDs; not necessary on platters (default: false)
 * `node[:cassandra][:config][:trickle_fsync_interval_in_kb]` Interval for fsync when doing sequential writes (default: 10240)
 * `node[:cassandra][:config][:storage_port]` TCP port, for commands and data (default: 7000)
 * `node[:cassandra][:config][:ssl_storage_port]` SSL port, unused unless enabled in encryption options (default: 7001)
 * `node[:cassandra][:config][:listen_address]` Address to bind for communication with other nodes. Leave blank to lookup IP from hostname. 0.0.0.0 is always wrong. (default: node[:ipaddress]).
 * `node[:cassandra][:config][:broadcast_address]` Address to broadcast to other Cassandra nodes.  If '', will use listen\_address (default: '')
 * `node[:cassandra][:config][:start_native_transport]` Whether to start the native transport server (default: true)
 * `node[:cassandra][:config][:native_transport_port]` Port for the CQL native transport to listen for clients on (default: 9042)
 * `node[:cassandra][:config][:start_rpc]` Whether to start the Thrift RPC server (default: true)
 * `node[:cassandra][:config][:rpc_address]` Address to bind the Thrift RPC server to. Leave blank to lookup IP from hostname.  0.0.0.0 to listen on all interfaces.  (default: node[:ipaddress])
 * `node[:cassandra][:config][:rpc_port]` Port for Thrift RPC server to listen for clients on (default: 9160)
 * `node[:cassandra][:config][:rpc_keepalive]` Enable keepalive on RPC connections (default: true)
 * `node[:cassandra][:config][:rpc_server_type]` sync for one thread per connection; hsha for "half synchronous, half asynchronous" (default: sync)
 * `node[:cassandra][:config][:thrift_framed_transport_size_in_mb]` Frame size for Thrift (maximum field length) (default: 15)
 * `node[:cassandra][:config][:thrift_max_message_length_in_mb]` Max length of a Thrift message, including all fields and internal Thrift overhead (default: 16)
 * `node[:cassandra][:config][:incremental_backups]` Enable hardlinks in backups/ for each sstable flushed or streamed locally. Removing these links is the operator's responsibility (default: false)
 * `node[:cassandra][:config][:snapshot_before_compaction]` Take a snapshot before each compaction (default: false)
 * `node[:cassandra][:config][:auto_snapshot]` Take a snapshot before keyspace truncation or dropping of column families.  If you set this value to false, you will lose data on truncation or drop (default: true)
 * `node[:cassandra][:config][:column_index_size_in_kb]` Add column indexes to a row after its contents reach this size (default: 64)
 * `node[:cassandra][:config][:compaction_throughput_mb_per_sec]` Throttle compaction to this total system throughput. Generally should be 16-32 times data insertion rate (default: 16)
 * `node[:cassandra][:config][:read_request_timeout_in_ms]` How long the coordinator should wait for read operations to complete (default: 10000)
 * `node[:cassandra][:config][:range_request_timeout_in_ms]` How long the coordinator should wait for seq or index scans to complete (default: 10000).
 * `node[:cassandra][:config][:write_request_timeout_in_ms]` How long the coordinator should wait for writes to complete (default: 10000)
 * `node[:cassandra][:config][:truncate_request_timeout_in_ms]` How long the coordinator should wait for truncates to complete (default: 60000)
 * `node[:cassandra][:config][:request_timeout_in_ms]` Default timeout for other, miscellaneous operations (default: 10000)
 * `node[:cassandra][:config][:cross_node_timeout]` Enable operation timeout information exchange between nodes to accurately measure request timeouts. Be sure ntp is installed and node times are synchronized before enabling. (default: false)
 * `node[:cassandra][:config][:streaming_socket_timeout_in_ms]` Enable socket timeout for streaming operation (default: 0 - no timeout).
 * `node[:cassandra][:config][:phi_convict_threshold]` Adjusts the sensitivity of the failure detector on an exponential scale (default: 8)
 * `node[:cassandra][:config][:endpoint_snitch]` SimpleSnitch, PropertyFileSnitch, GossipingPropertyFileSnitch, RackInferringSnitch, Ec2Snitch, Ec2MultiRegionSnitch (default: SimpleSnitch)
 * `node[:cassandra][:config][:dynamic_snitch_update_interval_in_ms]` How often to perform the more expensive part of host score calculation (default: 100)
 * `node[:cassandra][:config][:dynamic_snitch_reset_interval_in_ms]` How often to reset all host scores, allowing a bad host to possibly recover (default: 600000)
 * `node[:cassandra][:config][:dynamic_snitch_badness_threshold]` Allow 'pinning' of replicas to hosts in order to increase cache capacity. (default: 0.1)
 * `node[:cassandra][:config][:request_scheduler]` Class to schedule incoming client requests (default: org.apache.cassandra.scheduler.NoScheduler)
 * `node[:cassandra][:config][:index_interval]` index\_interval controls the sampling of entries from the primary row index in terms of space versus time (default: 128).
 * `node[:cassandra][:config][:auto_bootstrap]` Setting this parameter to false prevents the new nodes from attempting to get all the data from the other nodes in the data center. (default: true).
 * `node[:cassandra][:config][:enable_assertions]` Enable JVM assertions.  Disabling this in production will give a modest performance benefit (around 5%) (default: true).
 * `node[:cassandra][:config][:data_file_directories]` (default: node['cassandra']['data_dir']): C* data cirectories
 * `node[:cassandra][:config][:saved_caches_directory]` (default: saved_caches_directory): C* saved cache directory
 * `node[:cassandra][:config][:commitlog_directory]` (default: node['cassandra']['commitlog_dir']) *C commit log directory

#### C* <v2.0 Attributes

 * `node[:cassandra][:config][:memtable_flush_queue_size]` Number of full memtables to allow pending flush, i.e., waiting for a writer thread (default: 4)
 * `node[:cassandra][:config][:in_memory_compaction_limit_in_mb]` Size limit for rows being compacted in memory (default: 64)
 * `node[:cassandra][:config][:concurrent_compactors]` Sets the number of concurrent compaction processes allowed to run simultaneously on a node. (default: nil, which will result in one compaction process per CPU core)
 * `node[:cassandra][:config][:multithreaded_compaction]` Enable multithreaded compaction. Uses one thread per core, plus one thread per sstable being merged. (default: false)
 * `node[:cassandra][:config][:compaction_preheat_key_cache]` Track cached row keys during compaction and re-cache their new positions in the compacted sstable. Disable if you use really large key caches (default: true)
 * `node[:cassandra][:config][:native_transport_min_threads]` Min number of threads for handling transport requests when the native protocol is used (default: nil)
 * `node[:cassandra][:config][:native_transport_max_threads]` Max number of threads for handling transport requests when the native protocol is used (default: nil)

#### C* >v2.1 Attributes

 * `node[:cassandra][:config][:broadcast_rpc_address]` RPC address to broadcast to drivers and other Cassandra nodes (default: node[:ipaddress])
 * `node[:cassandra][:config][:tombstone_failure_threshold]` tombstone attribute, check C* documentation for more info (default: 100000)
 * `node[:cassandra][:config][:tombstone_warn_threshold]` tombstone attribute, check C* documentation for more info (default: 1000)
 * `node[:cassandra][:config][:sstable_preemptive_open_interval_in_mb]` This helps to smoothly transfer reads between the sstables, reducing page cache churn and keeping hot rows hot (default: 50)
 * `node[:cassandra][:config][:memtable_allocation_type]` Specify the way Cassandra allocates and manages memtable memory (default: heap_buffers)
 * `node[:cassandra][:config][:index_summary_capacity_in_mb]` A fixed memory pool size in MB for for SSTable index summaries. If left empty, this will default to 5% of the heap size (default: nil)
 * `node[:cassandra][:config][:index_summary_resize_interval_in_minutes]` How frequently index summaries should be resampled (default: 60)
 * `node[:cassandra][:config][:concurrent_counter_writes]` Concurrent writes, since writes are almost never IO bound, the ideal number of "concurrent_writes" is dependent on the number of cores in your system; (8 * number_of_cores) (default: 32)
 * `node[:cassandra][:config][:counter_cache_save_period]` Duration in seconds after which Cassandra should save the counter cache (keys only) (default: 7200)
 * `node[:cassandra][:config][:counter_cache_size_in_mb]` Counter cache helps to reduce counter locks' contention for hot counter cells. Default value is empty to make it "auto" (min(2.5% of Heap (in MB), 50MB)). Set to 0 to disable counter cache. (default: nil)
 * `node[:cassandra][:config][:counter_write_request_timeout_in_ms]` How long the coordinator should wait for counter writes to complete (default: 5000)
 * `node[:cassandra][:config][:commit_failure_policy]` policy for commit disk failures (default: stop)
 * `node[:cassandra][:config][:cas_contention_timeout_in_ms]` How long a coordinator should continue to retry a CAS operation that contends with other proposals for the same row (default: 1000)
 * `node[:cassandra][:config][:batch_size_warn_threshold_in_kb]` Log WARN on any batch size exceeding this value. 5kb per batch by default (default: 5)
 * `node[:cassandra][:config][:batchlog_replay_throttle_in_kb]` Maximum throttle in KBs per second, total. This will be reduced proportionally to the number of nodes in the cluster (default: 1024)



### JAMM Attributes

 * `node[:cassandra][:setup_jamm]` (default: false): install the jamm jar file and use it to set java option `-javaagent`, obsolete for C* versions `>v0.8.0`
 * `node[:cassandra][:jamm][:sha256sum]` (default: e3dd1200c691f8950f51a50424dd133fb834ab2ce9920b05aa98024550601cc5): jamm lib sha256sum for version `0.2.5`
 * `node[:cassandra][:jamm][:base_url]` (default: calculated): jamm lib jar url
 * `node[:cassandra][:jamm][:jar_name]` (default: calculated): jamm lib jar name
 * `node[:cassandra][:jamm][:version]` (default: calculated): jamm lib version

### JNA Attributes (Prior C* version 2.1.0)

 *  `node[:cassandra][:jna][:base_url]` The base url to fetch the JNA jar (default: https://github.com/twall/jna/tree/4.0/dist)
 *  `node[:cassandra][:jna][:jar_name]` The name of the jar to download from the base url. (default: jna.jar)
 *  `node[:cassandra][:jna][:sha256sum]` The SHA-256 checksum of the file. If the local jna.jar file matches the checksum, the chef-client will not re-download it. (default: dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19)


### Priam Attributes

 * `node[:cassandra][:setup_priam]` (default: false): install the priam jar file and use it to set java option `-javaagent`, uses the priam version corresponding to the cassandra version
 * `node[:cassandra][:priam][:sha256sum]` (default: 9fde9a40dc5c538adee54f40fa9027cf3ebb7fd42e3592b3e6fdfe3f7aff81e1): priam lib sha256sum for version `2.2.0`
 * `node[:cassandra][:priam][:base_url]` (default: priam url on maven.org): priam lib jar url
 * `node[:cassandra][:priam][:jar_name]` (default: calculated): priam lib jar name

### Logback Attributes

 * `node[:cassandra][:logback][:file][:max_file_size]` (default: "20MB"): logback File appender log file rotation size
 * `node[:cassandra][:logback][:file][:max_index]` (default: 20): logback File appender log files max_index
 * `node[:cassandra][:logback][:file][:min_index]` (default: 1): logback File appender log files min_index
 * `node[:cassandra][:logback][:file][:pattern]` (default: "%-5level [%thread] %date{ISO8601} %F:%L - %msg%n"): logback File appender log pattern
 * `node[:cassandra][:logback][:stdout][:enable]` (default: true): enable logback STDOUT appender
 * `node[:cassandra][:logback][:stdout][:pattern]` (default: "%-5level %date{HH:mm:ss,SSS} %msg%n"): logback STDOUT appender log pattern


### Ulimit Attributes

 * `node[:cassandra][:limits][:memlock]` (default: "unlimited"): memory ulimit for Cassandra node process
 * `node[:cassandra][:limits][:nofile]` (default: 48000): file ulimit for Cassandra node process
 * `node[:cassandra][:limits][:nproc]` (default: "unlimited"): process ulimit for Cassandra node process


### Yum Attributes

 * `node[:cassandra][:yum][:repo]` (default: datastax): name of the repo from which to install
 * `node[:cassandra][:yum][:description]` (default: "DataStax Repo for Apache Cassandra"): description of the repo
 * `node[:cassandra][:yum][:baseurl]` (default: "http://rpm.datastax.com/community"): repo url
 * `node[:cassandra][:yum][:mirrorlist]` (default: nil): a mirrorlist file
 * `node[:cassandra][:yum][:gpgcheck]` (default: false): whether to use `gpgcheck`
 * `node[:cassandra][:yum][:enabled]` (default: true): whether the repo is enabled by default
 * `node[:cassandra][:yum][:options]` (default: ""): Additional options to pass to `yum_package`


### OpsCenter Attributes

#### DataStax Ops Center Server attributes
 * `node[:cassandra][:opscenter][:server][:package_name]` (default: opscenter-free)
 * `node[:cassandra][:opscenter][:server][:port]` (default: 8888)
 * `node[:cassandra][:opscenter][:server][:interface]` (default: 0.0.0.0)
 * `node[:cassandra][:opscenter][:server][:authentication]` (default: false)

#### DataStax Ops Center Agent Tarball attributes
 * `node[:cassandra][:opscenter][:agent][:download_url]` (default: "") Required. You need to specify
 agent download url, because that could be different for each opscenter server version. ( S3 is a great
 place to store packages )
 * `node[:cassandra][:opscenter][:agent][:checksum]` (default: `nil`)
 * `node[:cassandra][:opscenter][:agent][:install_dir]` (default: `/opt`)
 * `node[:cassandra][:opscenter][:agent][:install_folder_name]` (default: `opscenter_agent`)
 * `node[:cassandra][:opscenter][:agent][:binary_name]` (default: `opscenter-agent`) Introduced since Datastax changed agent binary name from opscenter-agent to datastax-agent. **Make sure to set it right if you are updating to 4.0.2**
 * `node[:cassandra][:opscenter][:agent][:server_host]` (default: "" ). If left empty, will use search to get IP by opscenter `server_role` role.
 * `node[:cassandra][:opscenter][:agent][:server_role]` (default: `opscenter_server`). Will be use for opscenter server IP lookup if `:server_host` is not set.
 * `node[:cassandra][:opscenter][:agent][:use_chef_search]` (default: `true`). Determines whether chef search will be used for locating the data agent server.
 * `node[:cassandra][:opscenter][:agent][:use_ssl]` (default: `false`)

#### DataStax Ops Center Agent Datastax attributes
 * `node[:cassandra][:opscenter][:agent][:package_name]` (default: "datastax-agent" ).
 * `node[:cassandra][:opscenter][:agent][:server_host]` (default: "" ). If left empty, will use search to get IP by opscenter `server_role` role.
 * `node[:cassandra][:opscenter][:agent][:server_role]` (default: `opscenter_server`). Will be use for opscenter server IP lookup if `:server_host` is not set.
 * `node[:cassandra][:opscenter][:agent][:use_ssl]` (default: `false`)


### Data Center and Rack Attributes

 * `node[:cassandra][:rackdc][:dc]` (default: "") The datacenter to specify in the cassandra-rackdc.properties file. (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:rack]` (default: "") The rack to specify in the cassandra-rackdc.properties file (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:prefer_local]` (default: "false") Whether the snitch will prefer the internal ip when possible, as the Ec2MultiRegionSnitch does. (GossipingPropertyFileSnitch only)


## Contributing

Create a branch, make the changes, then submit a pull request on GitHub
with a brief description of what you've done and why your changes
should be included.

Write new resource/attribute description to `README.md`

Run the tests (`rake`), ensuring they all pass.


## Copyright & License

Michael S. Klishin, Travis CI Development Team, and [contributors](https://github.com/michaelklishin/cassandra-chef-cookbook/graphs/contributors),
2012-2015.

Released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
