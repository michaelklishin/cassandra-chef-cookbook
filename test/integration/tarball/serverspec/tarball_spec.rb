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
