cassandra_version = "1.2.1"

default[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :seeds => "127.0.0.1",
  :version => cassandra_version,
  :tarball => {
    :url => "http://www.eu.apache.org/dist/cassandra/#{cassandra_version}/apache-cassandra-#{cassandra_version}-bin.tar.gz",
    :md5 => "bca870d48906172eb69ad60913934aee"
  },
  :user => "cassandra",
  :jvm  => {
    :xms => 32,
    :xmx => 512
  },
  :limits => {
    :memlock => 'unlimited',
    :nofile  => 48000
  },
  :installation_dir => "/usr/local/cassandra",
  :bin_dir          => "/usr/local/cassandra/bin",
  :lib_dir          => "/usr/local/cassandra/lib",
  :conf_dir         => "/etc/cassandra/",
  # commit log, data directory, saved caches and so on are all stored under the data root. MK.
  :data_root_dir    => "/var/lib/cassandra/",
  :log_dir          => "/var/log/cassandra/",
  :listen_address   => "localhost",
  :rpc_address      => "localhost"
}
