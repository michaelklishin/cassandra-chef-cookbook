require 'spec_helper'

describe 'opscenter-datastax-agent' do
  context 'installs, enables & runs the agent' do
    describe package('datastax-agent') do
      it { should be_installed }
    end

    describe service('datastax-agent') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
