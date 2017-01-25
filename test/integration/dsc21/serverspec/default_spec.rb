require 'spec_helper'

describe 'cassandra' do
  describe package('dsc21') do
    it { should be_installed }
  end

  describe service('cassandra') do
    it { should be_enabled }
  end

  describe service('cassandra') do
    it { should be_running }
  end
end

describe 'jmx port' do
  describe port(7199) do
    it { should be_listening.on('127.0.0.1').with('tcp') }
    it { should not_be_listening.on('0.0.0.0') }
  end
end
