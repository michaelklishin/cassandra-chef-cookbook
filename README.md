# Apache Cassandra Chef Cookbook

This is an OpsCode Chef cookbook for Apache Cassandra ([DataStax
Community Edition](http://www.datastax.com/products/community)) as
well as DataStax Enterprise.

It uses officially released packages and provides an Upstart service
script. It has limited support for adjustment of Cassandra
configuration parameters using Chef node attributes.

It was originally created for CI and development environments. More
attributes will be added over time, **feel free to contribute** what
you find missing!


## Supported Apache Cassandra Version

This cookbook currently provides

 * Cassandra 2.0.x via tarballs
 * Cassandra 2.0.x or 1.2.x (DataStax Community Edition) via packages.
 * DataStax Enterprise (DSE)

## Supported OS Distributions

 * Ubuntu 11.04 through 13.10 via DataStax apt repo.
 * RHEL/CentOS via DataStax yum repo.

## Recipes

Two provided recipes are `cassandra::tarball` and `cassandra::datastax`. The former uses official tarballs
and thus can be used to provision any specific version.

The latter uses DataStax repository via packages. You can install different versions (ex. dsc20 for v2.0) available in the repository by altering `:package_name` attribute (`dsc20` by default).

### DataStax Enterprise

You can also install the DataStax Enterprise edition by adding `node[:cassandra][:dse]` attributes according to the datastax.rb.

There are also recipes for DataStax opscenter installation ( `opscenter_agent_tarball`, `opscenter_agent_datastax` and `opscenter_server` ) along with attributes available for override (see below).

### JNA Support

The optional recipe cassandra::jna will install the jna.jar in the
`/usr/share/java/jna.jar`, and create a symbolic link to it on
`#{cassandra.lib\_dir}/jna.jar`, according to the [DataStax
documentation](http://www.datastax.com/documentation/cassandra/1.2/webhelp/cassandra/install/installJnaDeb.html).

## Core Attributes

 * `node[:cassandra][:version]` (default: a recent patch version): version to provision
 * `node[:cassandra][:tarball][:url]` and `node[:cassandra][:tarball][:md5]` specify tarball URL and MD5 chechsum used by the `cassandra::tarball` recipe.
  * Setting `node[:cassandra][:tarball][:url]` to "auto" (default) will download the tarball of the specified version from the Apache repository.
 * `node[:cassandra][:user]`: username Cassandra node process will use
 * `node[:cassandra][:heap_new_size]` set JVM `-Xmn`; if nil, defaults to `min(100MB * num_cores, 1/4 * heap size)`
 * `node[:cassandra][:max_heap_size]` set JVM `-Xms` and `-Xmx`; if nil, defaults to `max(min(1/2 ram, 1024MB), min(1/4 ram, 8GB))`
 * `node[:cassandra][:installation_dir]` (default: `/usr/local/cassandra`): installation directory
 * `node[:cassandra][:data_root_dir]` (default: `/var/lib/cassandra`): data directory root
 * `node[:cassandra][:log_dir]` (default: `/var/log/cassandra`): log directory
 * `node[:cassandra][:listen_address]` (default: node IP address): address clients will use to connect to the node
 * `node[:cassandra][:broadcast_address]` (default: node IP address): address to broadcast to other Cassandra nodes
 * `node[:cassandra][:rpc_address]` (default: node IP address): address to bind the RPC interface
 * `node[:cassandra][:seeds]` (default: `[node[:ipaddress]]`): an array of nodes this node will contact to discover cluster topology

### OpsCenter Attributes

#### DataStax Ops Center Server attributes
 * `node[:cassandra][:opscenter][:server][:package_name]` (default: opscenter-free)
 * `node[:cassandra][:opscenter][:server][:port]` (default: 8888)
 * `node[:cassandra][:opscenter][:server][:interface]` (default: 0.0.0.0)

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
 * `node[:cassandra][:opscenter][:agent][:use_ssl]` (default: `true`)

#### DataStax Ops Center Agent Datastax attributes
 * `node[:cassandra][:opscenter][:agent][:package_name]` (default: "datastax-agent" ).
 * `node[:cassandra][:opscenter][:agent][:server_host]` (default: "" ). If left empty, will use search to get IP by opscenter `server_role` role.
 * `node[:cassandra][:opscenter][:agent][:server_role]` (default: `opscenter_server`). Will be use for opscenter server IP lookup if `:server_host` is not set.
 * `node[:cassandra][:opscenter][:agent][:use_ssl]` (default: `true`)

### Data Center and Rack Attributes

 * `node[:cassandra][:rackdc][:dc]` (default: "") The datacenter to specify in the cassandra-rackdc.properties file. (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:rack]` (default: "") The rack to specify in the cassandra-rackdc.properties file (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:prefer_local]` (default: "false") Whether the snitch will prefer the internal ip when possible, as the Ec2MultiRegionSnitch does. (GossipingPropertyFileSnitch only)


### Advanced Attributes

 * `node[:cassandra][:hinted_handoff_enabled]` see http://wiki.apache.org/cassandra/HintedHandoff (default: true)
 * `node[:cassandra][:max_hint_window_in_ms]` The maximum amount of time a dead host will have hints generated (default: 10800000).
 * `node[:cassandra][:hinted_handoff_throttle_in_kb]` throttle in KB's per second, per delivery thread (default: 1024)
 * `node[:cassandra][:max_hints_delivery_threads]` Number of threads with which to deliver hints (default: 2)
 * `node[:cassandra][:authenticator]` Authentication backend (default: org.apache.cassandra.auth.AllowAllAuthenticator)
 * `node[:cassandra][:authorizer]` Authorization backend (default: org.apache.cassandra.auth.AllowAllAuthorizer)
 * `node[:cassandra][:permissions_validity_in_ms]` Validity period for permissions cache, set to0 to disable (default: 2000)
 * `node[:cassandra][:partitioner]` The partitioner to distribute keys across the cluster (default: org.apache.cassandra.dht.Murmur3Partitioner).
 * `node[:cassandra][:disk_failure_policy]` policy for data disk failures: stop, best\_effort, or ignore (default: stop)
 * `node[:cassandra][:key_cache_size_in_mb]` Maximum size of the key cache in memory. Set to 0 to disable, or "" for auto = (min(5% of Heap (in MB), 100MB)) (default: "", auto).
 * `node[:cassandra][:key_cache_save_period]` Duration in seconds after which key cache is saved to saved\_caches\_directory. (default: 14400)
 * `node[:cassandra][:row_cache_size_in_mb]` Maximum size of the row cache in memory, 0 to disable (default: 0)
 * `node[:cassandra][:row_cache_save_period]` Duration in seconds after which row cache is saved to saved\_caches\_directory, 0 to disable cache save. (default: 0)
 * `node[:cassandra][:row_cache_provider]` The provider for the row cache to use (default: SerializingCacheProvider)
 * `node[:cassandra][:commitlog_sync]` periodic to ack writes immediately with periodic fsyncs, or batch to wait until fsync to ack writes (default: periodic)
 * `node[:cassandra][:commitlog_sync_period_in_ms]` period for commitlog fsync when commitlog\_sync = periodic (default: 10000)
 * `node[:cassandra][:commitlog_sync_batch_window_in_ms]` batch window for fsync when commitlog\_sync = batch (default: 50)
 * `node[:cassandra][:commitlog_segment_size_in_mb]` Size of individual commitlog file segments (default: 32)
 * `node[:cassandra][:concurrent_reads]` Should be set to 16 * drives (default: 32)
 * `node[:cassandra][:concurrent_writes]` Should be set to 8 * cpu cores (default: 32)
 * `node[:cassandra][:memtable_flush_queue_size]` Number of full memtables to allow pending flush, i.e., waiting for a writer thread (default: 4)
 * `node[:cassandra][:trickle_fsync]` Enable this to avoid sudden dirty buffer flushing from impacting read latencies.  Almost always a good idea on SSDs; not necessary on platters (default: false)
 * `node[:cassandra][:trickle_fsync_interval_in_kb]` Interval for fsync when doing sequential writes (default: 10240)
 * `node[:cassandra][:storage_port]` TCP port, for commands and data (default: 7000)
 * `node[:cassandra][:ssl_storage_port]` SSL port, unused unless enabled in encryption options (default: 7001)
 * `node[:cassandra][:listen_address]` Address to bind for communication with other nodes. Leave blank to lookup IP from hostname. 0.0.0.0 is always wrong. (default: node[:ipaddress]).
 * `node[:cassandra][:broadcast_address]` Address to broadcast to other Cassandra nodes.  If '', will use listen\_address (default: '')
 * `node[:cassandra][:start_native_transport]` Whether to start the native transport server (default: true)
 * `node[:cassandra][:native_transport_port]` Port for the CQL native transport to listen for clients on (default: 9042)
 * `node[:cassandra][:start_rpc]` Whether to start the Thrift RPC server (default: true)
 * `node[:cassandra][:rpc_address]` Address to bind the Thrift RPC server to. Leave blank to lookup IP from hostname.  0.0.0.0 to listen on all interfaces.  (default: node[:ipaddress])
 * `node[:cassandra][:rpc_port]` Port for Thrift RPC server to listen for clients on (default: 9160)
 * `node[:cassandra][:rpc_keepalive]` Enable keepalive on RPC connections (default: true)
 * `node[:cassandra][:rpc_server_type]` sync for one thread per connection; hsha for "half synchronous, half asynchronous" (default: sync)
 * `node[:cassandra][:thrift_framed_transport_size_in_mb]` Frame size for Thrift (maximum field length) (default: 15)
 * `node[:cassandra][:thrift_max_message_length_in_mb]` Max length of a Thrift message, including all fields and internal Thrift overhead (default: 16)
 * `node[:cassandra][:incremental_backups]` Enable hardlinks in backups/ for each sstable flushed or streamed locally. Removing these links is the operator's responsibility (default: false)
 * `node[:cassandra][:snapshot_before_compaction]` Take a snapshot before each compaction (default: false)
 * `node[:cassandra][:auto_snapshot]` Take a snapshot before keyspace truncation or dropping of column families.  If you set this value to false, you will lose data on truncation or drop (default: true)
 * `node[:cassandra][:column_index_size_in_kb]` Add column indexes to a row after its contents reach this size (default: 64)
 * `node[:cassandra][:in_memory_compaction_limit_in_mb]` Size limit for rows being compacted in memory (default: 64)
 * `node[:cassandra][:multithreaded_compaction]` Enable multithreaded compaction. Uses one thread per core, plus one thread per sstable being merged. (default: false)
 * `node[:cassandra][:compaction_throughput_mb_per_sec]` Throttle compaction to this total system throughput. Generally should be 16-32 times data insertion rate (default: 16)
 * `node[:cassandra][:compaction_preheat_key_cache]` Track cached row keys during compaction and re-cache their new positions in the compacted sstable. Disable if you use really large key caches (default: true)
 * `node[:cassandra][:read_request_timeout_in_ms]` How long the coordinator should wait for read operations to complete (default: 10000)
 * `node[:cassandra][:range_request_timeout_in_ms]` How long the coordinator should wait for seq or index scans to complete (default: 10000).
 * `node[:cassandra][:write_request_timeout_in_ms]` How long the coordinator should wait for writes to complete (default: 10000)
 * `node[:cassandra][:truncate_request_timeout_in_ms]` How long the coordinator should wait for truncates to complete (default: 60000)
 * `node[:cassandra][:request_timeout_in_ms]` Default timeout for other, miscellaneous operations (default: 10000)
 * `node[:cassandra][:cross_node_timeout]` Enable operation timeout information exchange between nodes to accurately measure request timeouts. Be sure ntp is installed and node times are synchronized before enabling. (default: false)
 * `node[:cassandra][:streaming_socket_timeout_in_ms]` Enable socket timeout for streaming operation (default: 0 - no timeout).
 * `node[:cassandra][:snitch]` SimpleSnitch, PropertyFileSnitch, GossipingPropertyFileSnitch, RackInferringSnitch, Ec2Snitch, Ec2MultiRegionSnitch (default: SimpleSnitch)
 * `node[:cassandra][:dynamic_snitch_update_interval_in_ms]` How often to perform the more expensive part of host score calculation (default: 100)
 * `node[:cassandra][:dynamic_snitch_reset_interval_in_ms]` How often to reset all host scores, allowing a bad host to possibly recover (default: 600000)
 * `node[:cassandra][:dynamic_snitch_badness_threshold]` Allow 'pinning' of replicas to hosts in order to increase cache capacity. (default: 0.1)
 * `node[:cassandra][:request_scheduler]` Class to schedule incoming client requests (default: org.apache.cassandra.scheduler.NoScheduler)
 * `node[:cassandra][:index_interval]` index\_interval controls the sampling of entries from the primrary row index in terms of space versus time (default: 128).
 * `node[:cassandra][:auto_bootstrap]` Setting this parameter to false prevents the new nodes from attempting to get all the data from the other nodes in the data center. (default: true).
 * `node[:cassandra][:enable_assertions]` Enable JVM assertions.  Disabling this in production will give a modest performance benefit (around 5%) (default: true).
 * `node[:cassandra][:xss]`  JVM per thread stack-size (-Xss option) (default: 256k).
 * `node[:cassandra][:jmx_server_hostname]` java.rmi.server.hostname option for JMX interface, necessary to set when you have problems connecting to JMX) (default: false).

### JNA Attributes

 *  `node[:cassandra][:jna][:base_url]` The base url to fetch the JNA jar (default: https://github.com/twall/jna/tree/4.0/dist)
 *  `node[:cassandra][:jna][:jar_name]` The name of the jar to download from the base url. (default: jna.jar)
 *  `node[:cassandra][:jna][:sha256sum]` The SHA-256 checksum of the file. If the local jna.jar file matches the checksum, the chef-client will not re-download it. (default: dac270b6441ce24d93a96ddb6e8f93d8df099192738799a6f6fcfc2b2416ca19)

## Dependencies

OracleJDK 7, OpenJDK 7, OpenJDK 6 or Sun JDK 6.


## Contributing

Create a branch, make the changes, then submit a pull request on GitHub
with a brief description of what you've done and why your changes
should be included.


## Copyright & License

Michael S. Klishin, Travis CI Development Team, 2012-2014.

Released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/michaelklishin/cassandra-chef-cookbook/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

