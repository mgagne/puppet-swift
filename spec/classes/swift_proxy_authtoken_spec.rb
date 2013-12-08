require 'spec_helper'

describe 'swift::proxy::authtoken' do

  let :default_params do
    { :admin_user          => 'swift',
      :admin_tenant_name   => 'services',
      :admin_password      => 'password',
      :auth_host           => '127.0.0.1',
      :auth_port           => '35357',
      :auth_protocol       => 'http',
      :auth_admin_prefix   => false,
      :auth_uri            => false,
      :delay_auth_decision => 1,
      :admin_token         => false,
      :signing_dir         => '/var/cache/swift',
      :cache               => 'swift.cache' }
  end

  context "with default parameters" do

#      'auth_uri',

    [ 'admin_user',
      'admin_tenant_name',
      'admin_password',
      'auth_host',
      'auth_port',
      'auth_protocol',
      'delay_auth_decision',
      'cache',
      'include_service_catalog',
      'signing_dir'
    ].each do |config|
      it "configures #{config} of account-quotas filter" do
        should contain_swift_proxy_config(
          "filter:authtoken/#{config}").with_value(default_params[config.to_sym])
      end
    end

    it 'configures account-quotas filter' do
      should contain_swift_proxy_config(
          'filter:authtoken/paste.filter_factory'
        ).with_value('keystoneclient.middleware.auth_token:filter_factory')
      should contain_swift_proxy_config(
        'filter:authtoken/log_name').with_value('swift')
    end
  end

  describe 'when overriding admin_token' do
    let :params do
      { :admin_token => 'ADMINTOKEN' }
    end

    it 'should configure admin_token' do
      should contain_swift_proxy_config(
        'filter:authtoken/admin_token').with_value(params[:admin_token])
    end

    it 'should unconfigure username and password' do
      should contain_swift_proxy_config(
        'filter:authtoken/admin_user').with_ensure(:absent)
      should contain_swift_proxy_config(
        'filter:authtoken/admin_tenant_name').with_ensure(:absent)
      should contain_swift_proxy_config(
        'filter:authtoken/admin_password').with_ensure(:absent)
    end
  end

  describe "when overriding parameters" do
    let :params do
      { :admin_user          => 'swiftuser',
        :admin_tenant_name   => 'admin',
        :admin_password      => 'swiftpassword',
        :auth_host           => 'some.host',
        :auth_port           => '443',
        :auth_protocol       => 'https',
        :auth_admin_prefix   => '/keystone/admin',
        :delay_auth_decision => '0',
        :cache               => 'foo',
        :signing_dir         => '/home/swift/keystone-signing' }
    end

    [ 'admin_user',
      'admin_tenant_name',
      'admin_password',
      'auth_host',
      'auth_port',
      'auth_protocol',
      'delay_auth_decision',
      'cache',
      'include_service_catalog',
      'signing_dir'].each do |config|
        it "configures #{config} of account-quotas filter" do
          should contain_swift_proxy_config(
            "filter:authtoken/#{config}").with_value(params[config.to_sym])
        end
    end
  end

  describe 'when overriding auth_uri' do
    let :params do
      { :auth_uri => 'http://public.host/keystone/main' }
    end

    it 'configures auth_uri' do
      should contain_swift_proxy_config(
        'filter:authtoken/auth_uri').with_value(params[:auth_uri])
    end
  end

  [ 'keystone',
    'keystone/',
    '/keystone/',
    '/keystone/admin/',
    'keystone/admin/',
    'keystone/admin'
  ].each do |auth_admin_prefix|

    describe "with invalid auth_admin_prefix #{auth_admin_prefix}" do
      let :params do
        { :auth_admin_prefix => auth_admin_prefix }
      end
      it_raises "a Puppet::Error", /validate_re\(\): "#{auth_admin_prefix}" does not match/
    end
  end

  describe 'with default signing directory' do

    it 'creates signing_dir directory' do
      should contain_file('/var/cache/swift').with(
        :ensure => 'directory',
        :mode    => '0700',
        :owner   => 'swift',
        :group   => 'swift'
      )
    end
  end

end
