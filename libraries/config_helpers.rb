#
# Cookbook Name:: cassandra
# Libraries:: config_helpers
#

require 'yaml'

def cassandra_yaml_config(c)
  config = JSON.parse(c.to_hash.dup.to_json)
  config.each do |k, v|
    config.delete(k) if k.nil? || v.nil?
  end

  # remove eval attributes
  config['client_encryption_options'].delete('enable_advanced') # if config.key?('client_encryption_options')
  config['server_encryption_options'].delete('enable_advanced') # if config.key?('server_encryption_options')

  # delete num_tokens if vnodes is not set
  config.delete('num_tokens') unless node['cassandra']['vnodes']
  # delete initial_token if vnodes is set
  config.delete('initial_token') if node['cassandra']['vnodes']
  # remove row_cache_provider if row_cache_provider == SerializingCacheProvider
  config.delete('row_cache_provider') if config.key?('row_cache_provider') && config['row_cache_provider'] == 'SerializingCacheProvider'
  # remove commitlog_sync_period_in_ms if commitlog_sync_batch_window_in_ms is not set
  config.delete('commitlog_sync_period_in_ms') unless config.key?('commitlog_sync_batch_window_in_ms')
  # remove commitlog_sync_period_in_ms if commitlog_sync != periodic
  config.delete('commitlog_sync_period_in_ms') if config.key?('commitlog_sync') && config['commitlog_sync'] != 'periodic'
  # remove commitlog_sync_batch_window_in_ms if commitlog_sync == periodic
  config.delete('commitlog_sync_batch_window_in_ms') if config.key?('commitlog_sync') && config['commitlog_sync'] == 'periodic'

  config['start_rpc'] = cassandra_bool_config(config['start_rpc'])
  config['rpc_keepalive'] = cassandra_bool_config(config['rpc_keepalive'])
  Hash[config.sort].to_yaml
end

def cassandra_bool_config(config_val)
  if config_val.is_a?(String)
    config_val
  else
    if config_val
      'true'
    else
      'false'
    end
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
      Chef::Log.info('Cassandra seed discovery using Chef search is enabled')
      q = node['cassandra']['seed_discovery']['search_query'] ||
          "chef_environment:#{node.chef_environment} "\
          "AND role:#{node['cassandra']['seed_discovery']['search_role']} "\
          "AND cassandra_config_cluster_name:#{node['cassandra']['config']['cluster_name']}"
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

# eval packaged jamm jar version
def jamm_version(version)
  case version.to_s.strip
  when /^0.[0-7]/
    '0.2.5'
  when /^0.8/
    '0.2.2'
  when /^1|^2.0/
    '0.2.5'
  when /^2.1.[0-1]$/
    '0.2.6'
  when /^2.1.[2-3]$/
    '0.2.8'
  when /^2.1.11$/
    '0.3.1'
  when /^2.1/
    '0.3.0'
  when /^2.2/
    '0.3.1'
  when /^3.0/
    '0.3.1'
  end
end

def jamm_sha256sum(version)
  case version.to_s.strip
  when '0.2.2'
    'unknown'
  when '0.2.5'
    'b599dc7a58b305d697bbb3d897c91f342bbddefeaaf10a3fa156c93efca397ef'
  when '0.2.6'
    'c9577bba0321eeb5358fdea29634cbf124ae3742e80d729f3bd98e0e23726dbf'
  when '0.2.8'
    '79d44f1b911a603f0a249aa59ad6ea22aac9c9b211719e86f357646cdf361a42'
  when '0.3.0'
    'debe2f8137c703d81eb9623b457e82eee2b305d834c1a8cfb65ad1f9c8f31f95'
  when '0.3.1'
    'b599dc7a58b305d697bbb3d897c91f342bbddefeaaf10a3fa156c93efca397ef'
  end
end

# C* tarball sha256sum
def tarball_sha256sum(version)
  sha256sums = {
    '1.0.0' => '7d30f8c5fea71a5d0031a0630cf536a20f47c03d6f292a3394d42c447aad4942', '1.0.1' => '90f733a56ddd735c70f412cdabafd5b42a1f63d96c0ada906c2a38e3d3312ede', '1.0.10' => 'bcaad3192cfd650f643b97bdc7e695da425a3bbc6db6c80c9ce9f0210872dc9d',
    '1.0.11' => '86b8aa865697f75c280b46aa576eef5e2961b699d3f65a56f39b9e23c822cc83', '1.0.12' => '97f2896263960aa53faa201b07d5a89d531d5e2ab3d9d788e5fc5bc5e9ef985a', '1.0.2' => '1b35c0daaa84f38c67f80c29f37222746f6f1c82900421301d88634f06f0ac79',
    '1.0.3' => '1daeef80d5df5db234aee893cb49c3cf55f1a9136406ed0ee17f9f0473170258', '1.0.4' => 'b1ae1df31cb201b51db4fc5843e00eb34db998f10aff8bda31ee5d1b242d9fb7', '1.0.5' => 'd7c2edacddd91f4b01548747ae56c27e3bf2c20a3fc09826810530d3d33343c4',
    '1.0.6' => 'a1610344b78164d238415112f523639e8c33b0a3a14b427e8b910017cf060d13', '1.0.7' => 'd0f6062ab75b1348ac9bcc844b6bd7a57dcea5680fe586e25c749db589eddd8d', '1.0.8' => 'b8cc374752deb34b98797b7fb03b892332ebabfb37f4eae0c115482e19b659c6',
    '1.0.9' => '0c0597b4e5f5b6eff66d1b9c98ab806be9d2f38c95d5c968407914f5c76fcde1', '1.1.0' => 'ea763057a7b9e5d78a574f310df3081a406af3de9d336d155a679e14d461b303', '1.1.1' => 'b3935a3d300c13a360ffe850672d0a5f767b9834ac6a870868d491ffd0ea2b89',
    '1.1.10' => '191ac7fc9f60bfdbe1f5682cb3bdcefcc53d9b5bfb943826fd6d73664d87815a', '1.1.11' => '246ff0348f6e45cb0d7d2c67245fb6d5fb891cbb35b86591416ffcfc183c6ccb', '1.1.12' => '3600f6e86e76974b38b2bf90fabff99ab2a443f444d55a93f3c677c8edbe3785',
    '1.1.2' => 'dfeacf663c74bc9de6949c96bbb46afd9567fcbe0925773bc59aad2a4e2e60e8', '1.1.3' => '485c1e0d3025d660a8df16e3c77c29b579f924a0ec6b552f075a417dd9204e64', '1.1.4' => '10d59524264a08cf59007856a0618c2a3f35a5590c0b807ea1a4f1172526998b',
    '1.1.5' => '08313fbfd5cc7d91a637a2a27c5c6bb4d3bf6ce8ff5eae9a14c20474faa8cf12', '1.1.6' => 'c21d568313fe7832d9a1b6be0ff39aa5febfee530a1941e89da65f49c6556171', '1.1.7' => 'cce6203c539d40d87a7a278bd056163440a43d75f9ef26ffa42dacbd57cb426a',
    '1.1.8' => 'c536232a7bd9ca189e9f1edb6dcaff349bb966d5bf74527d245d3b0b1b22327d', '1.1.9' => '2e86f29fdb1c4eb14b24db34dddbca409cc5176bf0b8e04521dc6fe9104f474d', '1.2.0' => '47bd459fd103a539ef148089f4c8050eeaa950b0b19a798f69905a942fc59510',
    '1.2.1' => '0b971ac9e27e48ecca54a4e45a19f26854482a25bdcba6b8b6f742b580e505f1', '1.2.10' => '8e759ca5f92745ad5e74c4e6ba1a0f3bf28cd6b0ff1d5a2a3c2adbc38b61236f', '1.2.11' => '008faeb5846b7a6e789caa0582056f8c95f361bef4d1939176f464fdb2d11f9a',
    '1.2.12' => '2883ca8d5103881bd3b27c76819598f1e67a2d7d299ef26d8b982a34fb787d17', '1.2.13' => 'b2430e6fb7039bf17fa6a72f33bd637864895b6316548f7fe3504c5c773b7dcb', '1.2.14' => 'dff728768e5ff2115ac41c2e9599bc4e5ed2f2fb67512c1b4c14bf0a093f7736',
    '1.2.15' => '9b35afb9d0fee7ac52858b4018ecf8bc69d7ad58049303a2ee8d44b8592b258b', '1.2.16' => '5ff7a844fca5ec326729001703aaca436543e560485ac50a1c9a5185c205ec46', '1.2.17' => 'fbd96369a113a3eabea7d784fe9f6cadf7598ade38443fa0d70d48ff66aaf576',
    '1.2.18' => '7f76aca107b8674d370bf4c37815027dd0d30e8f6e57b7471e050201729ddb92', '1.2.19' => '1c0c6e62dc612a43d6cb54bc70054876576a6cae7b90aca2162aa379df1b787e', '1.2.2' => '435c921864ec90ddb5be88af2f9023173a6f57c7bcb428f9ed0409a57484546f',
    '1.2.3' => 'b1860c4d3d6f667ead0c752e328c184c89893721f4d9237db1d9426b17dd4e6a', '1.2.4' => '0679c170b97f95b1677ae3f3e03cfa80a1dc645af5f1236f9a389f8610390a9a', '1.2.5' => '45d7c89000c0f2c8bc44de2de1bfb2943b74517591361ce8d3f4d97ad4508a0c',
    '1.2.6' => '0535c2888c9b057fe987ff8468f5dce5830d0b935b2ff1d61c4077b59f27d79c', '1.2.7' => '2c43e8e42a5980679f6375e88131b307784c0c8be8ff92710ae202e89a71c8c7', '1.2.8' => '664198714f31089e2b4cb7b3e0c329483a5e1d2d82563bf0e4fd345350e8f980',
    '1.2.9' => '786202a03320bd3fe4ac60c515a322075d1aa3ca15e0860ea3598c6e097baa15', '2.0.0' => '53b101481d0ff528e5dde1ee35cd92107719c0265fb0bfebb0e5cd3fe89e403d', '2.0.1' => '4e25ece07320667ba38a142063080bc18e4d37d7c010ce7b2f2d7c2af3d8740b',
    '2.0.10' => '962ab35b1767ed4c56eb9a2a6b9df374097dc48d4f1c718945cab3a977e5d9fa', '2.0.11' => 'f74c94e63c9dcb0cef6b627ea80ee0ad86da46ad7e7318bc6adf6821861d286b', '2.0.12' => 'af6f59e7b187d5c9744fd791156d24fd6cef8b3f65bf3dcbe5ae9400817abe88',
    '2.0.13' => '384cd45ec9c26e7b88250a212b79b82659e1687e2227e5cd5a2920fb25fe7764', '2.0.14' => '5396cda7a66929e9c9ea0a2eeb9f2b54327df1a42f407bc82fb1cc1648d87a1b', '2.0.15' => '007a4601c84ccb22b8a4e301d4102c2dbebde07ac9bb7e5d7581271a91ab3d03',
    '2.0.16' => 'c523deaaefd3450dcdda0d53e0f93243dd51b018ec32f6bca5c1f73a557dfbba', '2.0.2' => 'f65ed7821a2744a055535571923461c9ef8020242aac0a406f96e9f7cbce2819', '2.0.3' => '8129040b84ad086898f8a99680fd6eb54bb1ba81983d33f7217ec1ae0bb92607',
    '2.0.4' => 'f0be26d5a6a4e41fc5c0fdff8ecc4e5250c4a5cf45497904566f795bea1a2c35', '2.0.5' => '3b61ca8da88c6a14e4079b76de3052c53041ebb717a362f0d7489e775381e7c6', '2.0.6' => 'e7679bddb3029f87cf50936bc348cc07a9e6c557cd9a553aa69542d06a3d274a',
    '2.0.7' => '9ef94b58ab863d402f3827d5e98c7d01bf4ce02ec8383bdbf97218aced6694a7', '2.0.8' => '7d81ddf7e8ebe59ffa5ff5ace25171a56eb77404c9a5d1675a5031a17e85447e', '2.0.9' => '9cd8378235809007406d493e87ffa0e873b6868a2a7a351f7fbffe9614fa9845',
    '2.1.0' => 'da99c4ebc8de925dc6b493443b70d2183cf3090b1aad6b6b918efa9565f264dd', '2.1.1' => 'e9d10c2ccc6124d516772e672aef61732f763ff326967dc7fbcc3f1123a29901', '2.1.2' => '995182b62aada179648146a8fdd6f61881b23a33e77fe92c666c1816dad897be',
    '2.1.3' => 'df4ef06cd86c6c8a6bc1afee982279250a7a500aac20de55da48e43d0e3cebc3', '2.1.4' => 'fb5debada72905f169866ca43c21ade4782f9c036b160894e42b9072190cb7f1', '2.1.5' => '2d768e2fba9c576289e26247e2ed0b36fb802e06fa0a141783b765d63daf36ff',
    '2.1.6' => 'c2123b9d82b57868ad03c57720d9f4c99934fe292d571242a3b51337063409f7', '2.1.7' => 'add1a34b8e07dacb16df6b8dbe50c66d77cb46b89f66424103e2fd4459b79089', '2.1.8' => '3a0cc64efd529ffdc1600f6b3ad1946af85cc01544e2b469499aa81b10b722f5',
    '2.1.9' => '7a33598d3b06cfbf9fd1264f1ad03a03a3d2c716c2e941b79b134cd2e781dc82', '2.2.0' => '6405eb063e7c8a44a485ac12b305c00ad62c526cc021bcce145c29423ae7b0a2', '2.2.1' => '06cad23535333b4dd72596bc9bd0606afd1a1ea74f2a91df571e3e00c51c473f'
  }
  sha256sum = sha256sums[version]
  fail "sha256sum is missing for cassandra tarball version #{sha256sum}" unless sha256sum
  sha256sum
end
