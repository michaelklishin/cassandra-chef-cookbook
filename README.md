# Apache Cassandra Chef Cookbook

This is an OpsCode Chef cookbook for Apache Cassandra ([DataStax Community Edition](http://www.datastax.com/products/community)).

It uses officially released Debian packages, provides Upstart service script. It has limited
support for adjustment of Cassandra configuration parameters using Chef node attributes. The reason for
that is it was created for CI and development environments. More attributes will be added over time,
**feel free to contribute** what you find missing!


## Supported Apache Cassandra Version

This cookbook currently provides

 * Cassandra 2.0.x via tarballs
 * Cassandra 2.0.x or 1.2.x (DataStax Community Edition) via packages.

## Supported OS Distributions

 * Ubuntu 11.04 through 13.04 via DataStax apt repo.
 * RHEL/CentOS via DataStax yum repo.

## Recipes

Two provided recipes are `cassandra::tarball` and `cassandra::datastax`. The former uses official tarballs
and thus can be used to provision any specific version.

The latter uses DataStax repository via packages. You can install different versions (ex. dsc20 for v2.0) available in the repository by altering `:package_name` attribute (dsc12 by default).

**RHEL only at the moment!**
There are also two recipes for DataStax opscenter installation ( `opscenter_agent` and `opscenter_server` ) along with attributes available for override (see below).

## Attributes

 * `node[:cassandra][:version]` (default: a recent patch version): version to provision
 * `node[:cassandra][:tarball][:url]` and `node[:cassandra][:tarball][:md5]` specify tarball URL and MD5 chechsum used by the `cassandra::tarball` recipe.
  * Setting `node[:cassandra][:tarball][:url]` to "auto" (default) will download the tarball of the specified version from the Apache repository.
 * `node[:cassandra][:user]`: username Cassandra node process will use
 * `node[:cassandra][:jvm][:xms]` (default: `32`) and `node[:cassandra][:jvm][:xmx]` (default: `512`) control JVM `-Xms` and `-Xms` flag values, in megabytes (no need to add the `m` suffix)
 * `node[:cassandra][:installation_dir]` (default: `/usr/local/cassandra`): installation directory
 * `node[:cassandra][:data_root_dir]` (default: `/var/lib/cassandra`): data directory root
 * `node[:cassandra][:log_dir]` (default: `/var/log/cassandra`): log directory
 * `node[:cassandra][:rpc_address]` (default: `localhost`): address to bind the RPC interface

 * `node[:cassandra][:opscenter][:server][:package_name]` (default: opscenter-free)

 * `node[:cassandra][:opscenter][:agent][:download_url]` (default: "") Required. You need to specify
 agent download url, because that could be different for each opscenter server version. ( S3 is a great
 place to store packages )
 * `node[:cassandra][:opscenter][:agent][:checksum]` (default: "") Required.
 * `node[:cassandra][:opscenter][:agent][:install_dir]` (default: `/opt`)
 * `node[:cassandra][:opscenter][:agent][:install_folder_name]` (default: `opscenter_agent`)
 * `node[:cassandra][:opscenter][:agent][:server_host]` (default: "" ). If left empty, will use search to get IP by opscenter `server_role` role.
 * `node[:cassandra][:opscenter][:agent][:server_role]` (default: `opscenter_server`). Will be use for opscenter server IP lookup if `:server_host` is not set.
 * `node[:cassandra][:opscenter][:agent][:use_ssl]` (default: `true`)

 * `node[:cassandra][:rackdc][:dc]` (default: "") The datacenter to specify in the cassandra-rackdc.properties file. (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:rack]` (default: "") The rack to specify in the cassandra-rackdc.properties file (GossipingPropertyFileSnitch only)
 * `node[:cassandra][:rackdc][:prefer_local]` (default: "false") Whether the snitch will prefer the internal ip when possible, as the Ec2MultiRegionSnitch does. (GossipingPropertyFileSnitch only)

### Advanced attributes

 * `node[:cassandra][:max_hint_window_in_ms]` The maximum amount of time a dead host will have hints generated (default: 10800000).
 * `node[:cassandra][:partitioner]` The partitioner to distribute keys across the cluster (default: org.apache.cassandra.dht.Murmur3Partitioner).
 * `node[:cassandra][:key_cache_size_in_mb]` Default value is empty to make it "auto" (min(5% of Heap (in MB), 100MB)) (default: "").
 * `node[:cassandra][:broadcast_address]` = Address to broadcast to other Cassandra nodes (default: node[:ipaddress]).
 * `node[:cassandra][:range_request_timeout_in_ms]` How long the coordinator should wait for seq or index scans to complete (default: 10000).
 * `node[:cassandra][:streaming_socket_timeout_in_ms]` Enable socket timeout for streaming operation (default: 0 - no timeout).
 *  `node[:cassandra][:index_interval]` index\_interval controls the sampling of entries from the primrary row index in terms of space versus time (default: 128).
 *  `node[:cassandra][:auto_bootstrap]` Setting this parameter to false prevents the new nodes from attempting to get all the data from the other nodes in the data center. (default: true).
 *  `node[:cassandra][:enable_assertions]` Enable JVM assertions.  Disabling this in production will give a modest performance benefit (around 5%) (default: true).
 *  `node[:cassandra][:xss]`  JVM per thread stack-size (-Xss option) (default: 256k).
 *  `node[:cassandra][:jmx_server_hostname]` java.rmi.server.hostname option for JMX interface, necessary to set when you have problems connecting to JMX) (default: false).

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

