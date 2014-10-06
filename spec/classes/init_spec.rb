require 'spec_helper'
describe 'htcondor_auto_nagios' do

  context 'with defaults for all parameters' do
    it { should contain_class('htcondor_auto_nagios') }
  end
end
