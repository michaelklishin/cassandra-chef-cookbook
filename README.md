# Apache Cassandra Chef Cookbook

This is an OpsCode Chef cookbook for Apache Cassandra ([DataStax Community Edition](http://www.datastax.com/products/community)).

It uses officially released Debian packages, provides Upstart service script but has no
way to tweak Cassandra configuration parameters using Chef node attributes. The reason for
that is it was created for CI and development environments. Attributes will be used in the future,
doing so for single-server installations won't be difficult.


## Apache Cassandra Version

This cookbook currently provides Apache Cassandra 1.0.x (DataStax Community Edition).

## Supported OS Distributions

Ubuntu 11.04, 11.10.


## Recipes

Main recipe is `cassandra::datastax`.


## Attributes

This cookbook is very bare bones and targets development and CI environments, there are no attributes
at the moment.


## Dependencies

OpenJDK 6 or Sun JDK 6.


## Copyright & License

Michael S. Klishin, Travis CI Development Team, 2012.

Released under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
