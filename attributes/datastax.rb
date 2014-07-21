default[:cassandra][:conf_dir] = '/etc/cassandra/'

# Datastax have this as default name, and C* starts after package is installed
# so providing your own with force you to stop C* and clear data directories
#
