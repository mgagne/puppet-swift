require 'spec_helper'

describe 'swift::proxy::swift3' do

  let :facts do
    { :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian' }
  end

  let :default_params do
    { :ensure => 'present' }
  end

  let :params do
    {}
  end

  shared_examples_for 'swift3 filter' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_package('swift-plugin-s3').with_ensure(p[:ensure]) }

    it 'configures swift3 filter' do
      should contain_swift_proxy_config(
          'filter:swift3/use').with_value('egg:swift#swift3')
    end
  end

  context 'with default parameters' do
    it_behaves_like 'swift3 filter'
  end

  context 'when overriding default parameters' do
    before do
      params.merge!(
       :ensure => 'latest'
      )
    end

    it_behaves_like 'swift3 filter'
  end
end
