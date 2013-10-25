
case node["platform_family"]
when "rhel"
  include_recipe "yum"

  yum_repository "datastax" do
    repo_name "datastax"
    description "DataStax Repo for Apache Cassandra"
    url "http://rpm.datastax.com/community"
    action :add
  end

  package "#{node[:cassandra][:opscenter][:server][:package_name]}" do
    action :install
  end

  service "opscenterd" do
    supports :restart => true, :status => true
    action [:enable, :start]
  end

end
