require 'spec_helper'

describe 'swift::proxy::ceilometer' do

  let :facts do
    { :osfamily => 'Debian' }
  end

  let :pre_condition do
    'class { "ssh::server::install": }
     class { "swift":
        swift_hash_suffix => "dummy"
     }'
  end

  it 'configures ceilometer filter' do
    should contain_swift_proxy_config(
      'filter:ceilometer/use').with_value('egg:ceilometer#swift')
  end

  it 'adds swift to ceilometer group' do
    should contain_user('swift').with_groups('ceilometer')
  end
end
