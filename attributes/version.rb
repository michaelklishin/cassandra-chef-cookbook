
case node[:cassandra][:version]
# Report if jamm version is not correct for 0.x or 1.x version
when /^0\./,/^1\./,/^2\.0/
  # < 2.1 Versions
  default[:cassandra][:log_config_files] = %w(log4j-server.properties)
  default[:cassandra][:jamm_version] = '0.2.5'
  default[:cassandra][:cassandra_old_version_20] = true
else
  # >= 2.1 Version
  default[:cassandra][:log_config_files] = %w(logback.xml logback-tools.xml)
  default[:cassandra][:setup_jna] = false
  default[:cassandra][:jamm_version] = '0.2.6'
  default[:cassandra][:cassandra_old_version_20] = false
end
