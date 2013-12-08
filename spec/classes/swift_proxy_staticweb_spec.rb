require 'spec_helper'

describe 'swift::proxy::staticweb' do

  it 'configures staticweb filter' do
    should contain_swift_proxy_config(
      'filter:staticweb/use').with_value('egg:swift#staticweb')
  end
end
