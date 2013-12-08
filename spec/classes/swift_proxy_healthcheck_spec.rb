require 'spec_helper'

describe 'swift::proxy::healthcheck' do

  it 'configures healthcheck filter' do
    should contain_swift_proxy_config(
      'filter:healthcheck/use').with_value('egg:swift#healthcheck')
  end
end
