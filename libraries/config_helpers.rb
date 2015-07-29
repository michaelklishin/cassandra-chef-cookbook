#
# Cookbook Name:: cassandra-dse
# Libraries:: config_helpers
#

require 'yaml'

def cassandra_bool_config(config_val)
  if config_val.is_a?(String)
    return config_val
  elsif config_val
    return 'true'
  else
    return 'false'
  end
end

def hash_to_yaml_string(hash)
  hash.to_hash.to_yaml
end
