require 'spec_helper'

describe 'swift::proxy::cache' do

  let :facts do
    { :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
      :processorcount  => 1 }
  end

  let :default_params do
    { :memcache_servers => ['127.0.0.1:11211'] }
  end

  let :params do
    {}
  end

  let :pre_condition do
    ''
  end

  shared_examples_for 'configures cache filter' do
    let :p do
      default_params.merge(params)
    end

    it 'configures use' do
      should contain_swift_proxy_config(
        "filter:cache/use").with_value('egg:swift#memcache')
    end

    it 'configures memcache_servers' do
      if p[:memcache_servers].kind_of?(Array)
        expected = p[:memcache_servers].join(',')
      else
        expected = p[:memcache_servers]
      end
      should contain_swift_proxy_config(
        "filter:cache/memcache_servers").with_value(expected)
    end
  end

  context 'when using default parameters' do
    it_behaves_like 'configures cache filter'
  end

  context 'when overriding default parameters' do

    context 'with local memcache_servers' do
      before do
        params.merge!(:memcache_servers => '127.0.0.1:11211')
        pre_condition = 'class { "memcached": max_memory => 1 }'
      end

      it 'requires Memcached class' do
        should contain_class('Class[memcached]').with_before(
          'Class[Swift::Proxy::Cache]')
      end
    end

    context 'with memcache_servers with 1 item (String)' do
      before do
        params.merge!(:memcache_servers => '10.0.0.10:11211')
      end
      it_behaves_like 'configures cache filter'
    end

    context 'with memcache_servers with 1 item (Array)' do
      before do
        params.merge!(:memcache_servers => ['10.0.0.1:1'])
      end
      it_behaves_like 'configures cache filter'
    end

    context 'with memcache_servers with 2 items (Array)' do
      before do
        params.merge!(:memcache_servers => ['10.0.0.1:1', '10.0.0.1:2'])
      end
      it_behaves_like 'configures cache filter'
    end
  end
end
