require 'spec_helper'

describe 'swift::proxy::tempauth' do

  it 'configures tempauth filter' do
    should contain_swift_proxy_config(
      'filter:tempauth/use').with_value('egg:swift#tempauth')
  end
end
