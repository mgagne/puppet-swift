require 'spec_helper'

describe 'swift::proxy' do

  let :facts do
    { :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
      :processorcount  => 1 }
  end

  let :default_params do
    { :port           => 8080,
      :pipeline       => ['healthcheck', 'cache', 'tempauth', 'proxy-server'],
      :workers        => facts[:processorcount],
      :allow_account_management => true,
      :account_autocreate => true,
      :log_headers    => false,
      :log_udp_host   => '',
      :log_udp_port   => '',
      :log_address    => '/dev/log',
      :log_level      => 'INFO',
      :log_facility   => 'LOG_LOCAL1',
      :log_handoffs   => true,
      :package_ensure => 'present' }
  end

  let :params do
    { :proxy_local_net_ip => '0.0.0.0' }
  end

  let :pre_condition do
    "class { swift: swift_hash_suffix => 'string' }"
  end

  shared_examples_for 'swift proxy' do
    let :p do
      default_params.merge(params)
    end

    it {
      should contain_service('swift-proxy').with(
        :ensure    => 'running',
        :provider  => 'upstart',
        :enable    => true,
        :hasstatus => true
      )
    }

    it {
      should contain_file('/etc/swift/proxy-server.conf').with(
        :ensure  => 'present',
        :owner   => 'swift',
        :group   => 'swift',
        :mode    => '0660',
        :require => 'Package[swift-proxy]'
      )
    }

    it 'configures swift-proxy pipeline' do
      expected_require = (p[:pipeline] - ['proxy-server']).map { |pipeline|
        'Class[Swift::Proxy::%s]' % pipeline.gsub('-', '_').capitalize
      }
      # NOTE(mgagne) Puppet flattens one element array to string
      #              Deal with it by converting expectation to string
      if expected_require.size == 1
        expected_require = expected_require[0]
      end

      should contain_swift_proxy_config(
          'pipeline:main/pipeline'
        ).with_value(
          p[:pipeline].join(' ')
        ).with_require(
          expected_require
        ).with_notify('Service[swift-proxy]')
    end

    it 'configures swift-proxy.conf' do
      { 'DEFAULT/bind_port'    => p[:port],
        'DEFAULT/workers'      => p[:workers],
        'DEFAULT/log_facility' => p[:log_facility],
        'DEFAULT/log_level'    => p[:log_level],
        'DEFAULT/log_headers'  => p[:log_headers],
        'DEFAULT/log_address'  => p[:log_address],
        'app:proxy-server/set log_facility'   => p[:log_facility],
        'app:proxy-server/set log_level'      => p[:log_level],
        'app:proxy-server/set log_address'    => p[:log_address],
        'app:proxy-server/log_handoffs'       => p[:log_handoffs],
        'app:proxy-server/account_autocreate' => p[:account_autocreate],
        'app:proxy-server/allow_account_management' => p[:allow_account_management]
      }.each do |param, value|
        should contain_swift_proxy_config(param).with_value(value)
      end
    end
  end

  context 'without required parameters' do
    before do
      params.clear
    end
    it_raises 'a Puppet::Error', /Must pass proxy_local_net_ip/
  end

  context 'with default parameters' do
    it_behaves_like 'swift proxy'
  end

  context 'when providing parameters' do
    before do
      params.merge!(
        :proxy_local_net_ip       => '10.0.0.2',
        :port                     => 80,
        :workers                  => 3,
        :pipeline                 => ['swauth', 'proxy-server'],
        :allow_account_management => false,
        :account_autocreate       => false,
        :log_level                => 'DEBUG'
      )
    end
    it_behaves_like 'swift proxy'
  end

  context 'with invalid parameters' do

    context 'with tempauth in pipeline and account_autocreate is false' do
      before do
        params.merge!(
          :pipeline           => ['tempauth'],
          :account_autocreate => false
        )
      end
      it_raises 'a Puppet::Error', /account_autocreate must be set to true when auth_type is tempauth/
    end

    context 'with invalid pipeline parameter' do
      before do
        params.merge!(:pipeline => 'foobar')
      end
      it_raises 'a Puppet::Error', /is not an Array/
    end

    context 'with invalid boolean parameters' do
      [ :account_autocreate,
        :allow_account_management
      ].each do |param|
        it "fails when #{param} is not passed a boolean" do
          params[param] = 'foobar'
          expect { subject }.to raise_error(Puppet::Error, /is not a boolean/)
        end
      end
    end
  end

  context 'without proper dependencies' do

    context 'without memcached being included' do
      let :pre_condition do
        "class { 'swift': swift_hash_suffix => 'string' }
         class { 'swift::proxy::healthcheck': }
         class { 'swift::proxy::cache': }
         class { 'swift::proxy::tempauth': }"
      end
      it_raises 'a Puppet::Error', /Could not find resource 'Class\[Memcached\]'/
    end
  end
end
