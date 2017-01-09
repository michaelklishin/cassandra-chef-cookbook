## Changes Between 4.2.0 and 4.3.0 (10-01-2017)

### systemd Support

Contributed by William Dauchy, Romain Gerard, Jean-Francois Weber-Marx.

### Update jamm Versions for Several Cassandra Series (e.g. 3.x)

Contributed by William Dauchy and Corentin Chary.

### Cassandra Version Changes Force Node Restarts

Thanks to a neat template generation trick by William Dauchy.

### Custom Sections in `opscenterd.conf`

Contributed by eyalzek.

### JMX Authentication Support

Contributed by Andrew Nolan.

### Make Sure that System Directory Permissions Are Unmodified

Contributed by Jean-Francois Weber-Marx.

### Bring Back Support for `native_transport_max_threads`

Contributed by Corentin Chary.

### Corrected `bin` Paths When Installing via Packages

Contributed by Barthelemy Vessemont.

### `cassandra_metrics` Are Now Configurable

Contrbuted by eyalzek.

### Ensure `source_dir` and `installation_dir` Minus the Leaf Directory Exist

Contributed by Michal Jankowski.

### Permissions of Optional JAR Files

...are now set to `0440`.

### Updated Package Checksums

Contributed by Michal Jankowski.

### Correctly Create `commitlog_dir` and `saved_caches_dir`

Contributed by Ryan Scheidter.



## Changes Between 4.1.0 and 4.2.0 (22-09-2016)

### More Reliable Upgrades

Contributed by Seth Rosenblum.

### Temp Directory Attributes

`cassandra.tmp_dir` is a new attribute that controls JNA and
JVM temporary directory (`java.io.tmpdir`) location.

Contributed by Jack Bracken.

### Jamm Version Updates for 3.x Releases

Contributed by Corentin Chary and Anthony Rabier.

### Hints Directory Not Set for C* 2.x

Hints directory is no longer set for C* 2.x as it's only
supported in 3.x.

Contributed by William Dauchy.

### More Reasonable Streaming Operation Socket Timeout

`cassandra.config.streaming_socket_timeout_in_ms` now defaults to 1 hour.

Contributed by Dimitris Verraros.

### Syslog Appender

Add syslog appender to log to remote servers.

Contributed by Andrew Nolan.

### More Reliable Data Directory Management

Contributed by Michael Saffitz.

### 3.x Package Naming Fixes

Contributed by Jason J. W. Williams.

### OpsCenter Agent [Chef] Environment Fixes

Contributed by Radek Wierzbicki.

### New 3.x Settings

Contributed by Otavio Fernandes.

### Java 8 JVM Tuning options

A number of tuning options have been added to the cookbook to provide more 
knobs to control performance in the JVM. This work is centered around the
use-case of Oracle JDK 8 with the G1 GC.
 
Contributed by Matthew Silvey.

## Changes Between 4.0.0 and 4.1.0 (Dec 28, 2015)

### DSE Compatibiilty Bug Fixes

For example, the `cassandra` package shouldn't be installed
when DSE is provisioned.

Contributed by Bill Warner and Dimitris Verraros.


### OpsCenter Agent Has TLS Disabled by Default

...and is now configured correctly when overridden.

Contributed by Michael Belt.


### Support Configuration of `commitlog_total_space_in_mb`

The attribute `node[:cassandra][:config][:commitlog_total_space_in_mb]` takes on the cassandra default of `4096` and may be reconfigured.

Contributed by Geoff Hichborn

### additional chefspec tests to at least cover all resources

Tested with chef 0.9.0 but prior and later versions should still work.

run with
```
rake unit
```

Contributed by Bill Warner.

### Default to localhost-only JMX

The attribute `node[:cassandra][:local_jmx]` defaults to `true` now, making
JMX listen on localhost only. This is the default since cassandra 2.0.14 and
2.1.4 and fixes the remote code execution exploit from CVE-2015-0225.

Should you choose to enable remote JMX access by setting this to false, be aware
that this cookbook currently does not support configuring authentication for JMX,
so you should limit access to the JMX port by other means, such as firewalling.

Contributed by Bernhard Weisshuhn.

### Priam Support

See `node[:cassandra][:setup_priam]` and related node attributes.

Contributed by Scott McMaster.


### init.d Script Fix (Debian)

Node IP address is now correctly passed to `nodetool`.

Contributed by Scott McMaster.

### Default Seed Discovery Fix

Default seed discovery query will now respect `node[:cassandra][:config][:cluster_name]`.

Contributed by Robert Berger.

### jamm Version Fix

The cookbook will now pick the correct jamm version for the Cassandra
version it is asked to provision.

Contributed by Robert Berger.


## Changes Between 3.5.0 and 4.0.0

`4.0.0` has **breaking changes in attribute structure**.

### Node Config Attributes Moved

Node configuration attributes are now under `node['cassandra']['config']`. Since
there are many of them, please [consult the default attributes file](https://github.com/michaelklishin/cassandra-chef-cookbook/blob/master/attributes/config.rb).

### SHA 256 Checksums

SHA256 is now used instead of MD5 for checksums. The cookbook
now provides checksums for Cassandra versions up to 2.2.0.

### 2.2.0 by Default

The cookbook now provisions Cassandra 2.2.0 by default.


## Changes Between 3.4.0 and 3.5.0

### Seed Discovery Using Chef Search

The cookbook will now use Chef search to discover seed nodes.
The exact query used is configurable. Search is disabled by default.

GH issues: [#204](https://github.com/michaelklishin/cassandra-chef-cookbook/issues/204),
[#205](https://github.com/michaelklishin/cassandra-chef-cookbook/pull/205).

The following node attribute snippet enables Chef search and will list
IP addresses of nodes with roles `cassandra` and `cassandra-seed`:

``` json
  "cassandra": {
    "seed_discovery": {
      "use_chef_search": true,
      "search_query": "role:cassandra-seed OR role:cassandra"
    }
  }
```


### `:data_dir` Array Handling

`cassandra-dse::tarball` now handles arrays of data dirs.

Contributed by Bryce Lynn.

GH issue: [#154](https://github.com/michaelklishin/cassandra-chef-cookbook/issues/154).



## Changes Between 3.3.0 and 3.4.0

### FD_LIMIT in Init Script

`FD_LIMIT` value in the init script is now corrently
set to the `node[:cassandra][:limits][:nofile]` value.

Contributed by Rich Schumacher.

GH issue: [#201](https://github.com/michaelklishin/cassandra-chef-cookbook/pull/201).



## Changes Between 3.2.0 and 3.3.0

### Ensure conf Directory Exists

If Cassandra conf directory doesn't exist, it will be created.

Contributed by Ahmed Ferdous.


## Changes Between 2.7.x and 3.2.0

The cookbook has a new name: `cassandra-dse`, and is [available from
Chef Supermarket](https://supermarket.chef.io/cookbooks/cassandra-dse).

Main recipe names is therefore now `cassandra-dse::default`.

Multiple bug fixes.


## Changes Between 2.7.0 and 2.7.x

* Virender Khatri: Updated README for v2.1
* Virender Khatri: C* version 2.1.x version support
* Virender Khatri: Disabled <2.1 cassandra parameters for 2.1
* Virender Khatri: Added 2.1 cassandra parameters
* Virender Khatri: jamm_version attribute for C* version dependency
* Virender Khatri: Added logback config files for v2.1
* Virender Khatri: Disabled jna for v2.1 and later
* MikeB: Fixed check for Java Attribute UseCondCardMark addition for x86_64 arch
* Virender Khatri: Added yum node attributes for DSE
* Virender Khatri: Added apt node attributes for DSE/DSC
* Lars Pfannenschmidt: Fixed UseCondCardMark is only supported under 64-Bit systems
* Chris: Updated README for yum and jna attr
* Chris: Added yum node attributes for DSE
* Chris: Added Refactor attributes in .kitchen.yml
* Chris: Added node Oracle Java version for minimum Java version requirement
* Chris: Added java version for minimum Java version requirement
* Xynergy: Fixed C* release attribute for datastax
* Virender Khatri: Moved node C* sub directories attributes to recipe
* Virender Khatri: Added C* service notifies for init.d and other files
* Virender Khatri: Added few Java Parameters
* Virender Khatri: Renamed default attributesrb to common.rb and moved attributes among other attributes files
* Tim Nicholas: Added log4j root logger attribute
* Tim Nicholas: Added cassandra-rackdc.properties.erb for datastax recipe
* Tim Nicholas: Fixed directory/files structure and ownership for datastax recipe
* Tim Nicholas: Added C* encryption
* Anthony Acquanita: Updated README for datastax recipe being default
* Virender Khatri: Fixed indent and C* service name / notify
* Alex Groleau: Added node default service action attribute for C* service
* Alex Groleau: Fixed jna var issue
* Michael Klishin: Updated Changelog

## Changes Between 2.6.0 and 2.7.0

### Chef 11.10 Compatibility

Contributed by Virender Khatri.

### Extra Slash to File Between Path Components

`log_dir` now always has at least one slash, regardless of whether there
is a trailing slash in the user-provided attribute value.

GH issue: #86.

Contributed by Federico Silva.

### New Attribute for User Home (`$HOME`)

`user_home` is a new attribute that customizes Cassandra user `$HOME` location.

Contributed by Virender Khatri.

### Removed JNA Recipe

The JNA recipe is no longe needed.

Contributed by Virender Khatri.

### Default Attributes for DataStax Enterprise

The cookbook now provides default node attributes specific
to the DSE recipe.

Contributed by Anton Chebotaev.


## Changes Between 2.5.0 and 2.6.0

### Ubuntu 12.04 Compatibility

Contributed by Anton Chebotaev.


## Changes Between 2.4.0 and 2.5.0

### Chef-friendly Version

The cookbook now uses a 3 component version that's compatible
with Chef server (no longer uses `-pre` for dev versions).

Contributed by Anton Chebotaev.

### Init Script Improvements

 * Added check for C* binary
 * Added check for nodetool binary
 * Added extra pre-steps for C* service stop: disable thrift, disable gossip, node drain

Contributed by Virender Khatri.

### Disabling Xss Output in Nodetool

Contributed by Virender Khatri.

### Cassandra 2.0.9

Default Cassandra version provisioned is now `2.0.9`.

Contributed by Maksim Rusan.

### Corrected yum Package Release For DSC 2.0

Corrects yum package release for dsc20 2.0.8.

GH issue: #73.

Contributed by Brent Theisen.


## Changes Between 2.3.0 and 2.4.0

### apt Pinning

When package provisioning is used on Debianoids,
apt will be pinned to the exact version to avoid
unexpected upgrades.

Contributed by [klamontagne](https://github.com/klamontagne).
