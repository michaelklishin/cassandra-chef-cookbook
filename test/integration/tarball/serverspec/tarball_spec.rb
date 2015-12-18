require 'spec_helper'

describe 'cassandra' do
  it 'installs it' do
    expect(package 'dsc20').to be_installed
  end

  it 'is running' do
    expect(service 'cassandra').to be_running
  end

  it 'is enabled' do
    expect(service 'cassandra').to be_enabled
  end
end

describe 'jmx port' do
  describe port(7199) do
    it { should be_listening.on('127.0.0.1').with('tcp') }
    it { should not_be_listening.on('0.0.0.0') }
  end
end
