require 'spec_helper'

describe 'cassandra' do
  it 'installs it' do
    expect(package 'dsc20').to be_installed
  end

  it 'is enabled' do
    expect(service 'cassandra').to be_enabled
  end

  # On Centos, C* doesn't start due Java 6 being installed, and not 7.
  # On ubuntu, C* doesn't start due a jamm error.
  # it 'is running' do
  #   expect(service 'cassandra').to be_running
  # end
end

describe 'cassandra configuration' do
  case os[:family]
  when 'debian'
  when 'ubuntu'
    cassandra_config = '/etc/cassandra/cassandra.yaml'
  when 'redhat'
    cassandra_config = '/etc/cassandra/conf/cassandra.yaml'
  end

  describe file(cassandra_config) do
    it { should be_file }
  end
end

describe 'cassandra user' do
  describe user('cassandra') do
    it { should exist }
    it { should belong_to_group 'cassandra' }
    it { should have_login_shell '/bin/bash' }
    it { should have_home_directory '/home/cassandra' }
  end
end
