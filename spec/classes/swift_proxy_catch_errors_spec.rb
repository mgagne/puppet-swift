require 'spec_helper'

describe 'swift::proxy::catch_errors' do

  it 'configures catch_errors filter' do
    should contain_swift_proxy_config(
      'filter:catch_errors/use').with_value('egg:swift#catch_errors')
  end
end
