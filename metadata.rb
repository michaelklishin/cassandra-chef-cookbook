name 'cassandra-dse'
maintainer 'Michael S. Klishin'
maintainer_email 'michael@clojurewerkz.org'
license 'Apache 2.0'
description 'Installs/configures Apache Cassandra'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/michaelklishin/cassandra-chef-cookbook' if respond_to?(:source_url)
issues_url 'https://github.com/michaelklishin/cassandra-chef-cookbook/issues' if respond_to?(:issues_url)
version '4.6.0'
depends 'java', '< 8.0.0'
depends 'ulimit'
depends 'apt'
depends 'yum'
depends 'ark'
depends 'systemd'
depends 'chef_handler', '~> 3.0.2'

chef_version '>= 12.9.1'

%w[ubuntu centos redhat fedora amazon].each do |os|
  supports os
end
