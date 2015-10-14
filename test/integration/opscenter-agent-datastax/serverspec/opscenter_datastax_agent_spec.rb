require 'spec_helper'

describe 'opscenter-datastax-agent' do
  it 'installs, enables & runs the agent' do
    expect(package 'datastax-agent').to be_installed
    expect(service 'datastax-agent').to be_enabled
    expect(service 'datastax-agent').to be_running
  end
end
