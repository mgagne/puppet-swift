require 'spec_helper'

describe 'swift::proxy::tempurl' do

  it 'configures tempurl filter' do
    should contain_swift_proxy_config(
      'filter:tempurl/use').with_value('egg:swift#tempurl')
  end
end
