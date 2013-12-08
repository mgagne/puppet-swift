require 'spec_helper'

describe 'swift::proxy::swauth' do

  let :default_params do
    { :swauth_endpoint        => '127.0.0.1',
      :swauth_super_admin_key => 'swauthkey',
      :package_ensure         => 'present' }
  end

  let :params do
    {}
  end

  shared_examples_for 'swauth filter' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_package('python-swauth').with_ensure(p[:package_ensure]) }

    it 'configures swauth filter' do
      should contain_swift_proxy_config(
          'filter:swauth/use').with_value('egg:swift#swauth')
    end

    [ 'swauth_endpoint',
      'swauth_super_admin_key'
    ].each do |config|
      it "configures #{config} of swauth filter" do
        should contain_swift_proxy_config(
          "filter:swauth/#{config}").with_value(p[config.to_sym])
      end
    end
  end

  context 'with default parameters' do
    it_behaves_like 'swauth filter'
  end

  context 'when overriding default parameters' do
    before do
      params.merge!(
       :swauth_endpoint        => '10.0.0.1',
       :swauth_super_admin_key => 'foo',
       :package_ensure         => 'latest'
      )
    end

    it_behaves_like 'swauth filter'
  end
end

