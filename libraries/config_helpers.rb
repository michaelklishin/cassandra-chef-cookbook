#
# Cookbook Name:: cassandra
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

def discover_seed_nodes
  # use chef search for seed nodes
  if node['cassandra']['seed_discovery']['use_chef_search']
    if Chef::Config[:solo]
      Chef::Log.warn("Chef Solo does not support search, provide the seed nodes via node attribute node['cassandra']['seeds']")
      node['ipaddress']
    else
      Chef::Log.info("Cassandra seed discovery using Chef search is enabled")
      q = if search_query = node['cassandra']['seed_discovery']['search_query']
            search_query
          else
            "chef_environment:#{node.chef_environment} AND role:#{node['cassandra']['seed_discovery']['search_role']} AND cassandra_cluster_name:#{node['cassandra']['cluster_name']}"
          end
      Chef::Log.info("Will discover Cassandra seeds using query '#{q}'")
      xs = search(:node, q).map(&:ipaddress).sort.uniq
      Chef::Log.debug("Discovered #{xs.size} Cassandra seeds using query '#{q}'")

      if xs.empty?
        node['ipaddress']
      else
        xs.take(node['cassandra']['seed_discovery']['count']).join(',')
      end
    end
  else
    # user defined seed nodes
    if node['cassandra']['seeds'].is_a?(Array)
      node['cassandra']['seeds'].join(',')
    else
      node['cassandra']['seeds']
    end
  end
end
