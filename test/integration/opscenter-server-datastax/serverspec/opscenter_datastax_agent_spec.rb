require 'spec_helper'

describe 'opscenter-datastax-agent' do
  it 'installs, enables & runs the agent' do
    describe package('opscenter') do
      it { should be_installed }
    end

    describe service('opscenterd') do
      it { should be_enabled }
    end

    describe service('opscenterd') do
      it { should be_running }
    end
  end
end
