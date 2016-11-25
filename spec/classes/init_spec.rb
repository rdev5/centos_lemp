require 'spec_helper'
describe 'centos_lemp' do
  context 'with default values for all parameters' do
    it { should contain_class('centos_lemp') }
  end
end
