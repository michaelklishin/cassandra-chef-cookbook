Chef::Log.warn("cassandra::opscenter_agent is deprecated, please use cassandra::opscenter_agent_tarball or cassandra::opscenter_agent_datastax")
include_recipe "cassandra::opscenter_agent_tarball"
