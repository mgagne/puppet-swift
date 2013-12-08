require 'spec_helper'

describe 'swift::proxy::s3token' do

  let :default_params do
    { :auth_host     => '127.0.0.1',
      :auth_port     => 35357,
      :auth_protocol => 'http' }
  end

  let :params do
    {}
  end

  shared_examples_for 's3token filter' do
    let :p do
      default_params.merge(params)
    end

    it { should contain_class('keystone::python') }

    it {
      should contain_swift_proxy_config(
          'filter:s3token/use').with_value('egg:swift#s3token')
    }

    [ 'auth_host',
      'auth_port',
      'auth_protocol'
    ].each do |config|
      it {
        should contain_swift_proxy_config(
          "filter:s3token/#{config}").with_value(p[config.to_sym])
      }
    end
  end

  context 'with default parameters' do
    it_behaves_like 's3token filter'
  end

  context 'when overriding default parameters' do
    before do
      params.merge!(
        :auth_port     => 4212,
        :auth_protocol => 'https',
        :auth_host     => '1.2.3.4'
      )
    end

    it_behaves_like 's3token filter'
  end
end
