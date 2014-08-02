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
