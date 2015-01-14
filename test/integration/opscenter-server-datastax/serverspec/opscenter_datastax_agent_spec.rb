require 'spec_helper'

describe 'opscenter-datastax-agent' do

  it 'installs, enables & runs the agent' do
    expect(package 'opscenter').to be_installed
    expect(service 'opscenterd').to be_enabled
    expect(service 'opscenterd').to be_running
  end

end
