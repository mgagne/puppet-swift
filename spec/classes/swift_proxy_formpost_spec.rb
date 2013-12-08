require 'spec_helper'

describe 'swift::proxy::formpost' do

  it 'configures formpost filter' do
    should contain_swift_proxy_config(
      'filter:formpost/use').with_value('egg:swift#formpost')
  end
end
