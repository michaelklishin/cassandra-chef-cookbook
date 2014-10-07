
include_attribute "cassandra::common"

default[:cassandra][:package_name]  = 'dsc20'
default[:cassandra][:release]       = '1'

default[:cassandra][:yum][:repo] = "datastax"
default[:cassandra][:yum][:description] = "DataStax Repo for Apache Cassandra"
default[:cassandra][:yum][:baseurl] = "http://rpm.datastax.com/community"
default[:cassandra][:yum][:mirrorlist] = nil
default[:cassandra][:yum][:gpgcheck] = false
default[:cassandra][:yum][:enabled] = true
default[:cassandra][:yum][:options] = ""
