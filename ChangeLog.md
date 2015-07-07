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
