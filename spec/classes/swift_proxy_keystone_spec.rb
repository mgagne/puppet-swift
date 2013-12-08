require 'spec_helper'

describe 'swift::proxy::keystone' do

  let :default_params do
    { :operator_roles => ['admin', 'SwiftOperator'],
      :is_admin       => true }
  end

  let :params do
    {}
  end

  shared_examples_for 'configures keystone filter' do
    let :p do
      default_params.merge(params)
    end

    it 'configures filter' do
      should contain_swift_proxy_config(
        "filter:keystone/use").with_value('egg:swift#keystoneauth')
      should contain_swift_proxy_config(
        "filter:keystone/is_admin").with_value(p[:is_admin])
    end

    it 'configures operator_roles' do
      if p[:operator_roles].kind_of?(Array)
        expected = p[:operator_roles].join(', ')
      else
        expected = p[:operator_roles]
      end
      should contain_swift_proxy_config(
        "filter:keystone/operator_roles").with_value(expected)
    end
  end

  context 'when using default parameters' do
    it_behaves_like 'configures keystone filter'
  end

  context 'when overriding default parameters' do

    context 'with operator_roles with 1 item (String)' do
      before do
        params.merge!(:operator_roles => 'admin')
      end
      it_behaves_like 'configures keystone filter'
    end

    context 'with operator_roles with 1 item (Array)' do
      before do
        params.merge!(:operator_roles => ['admin'])
      end
      it_behaves_like 'configures keystone filter'
    end

    context 'with operator_roles with 2 items (Array)' do
      before do
        params.merge!(:operator_roles => ['admin', 'foo'])
      end
      it_behaves_like 'configures keystone filter'
    end
  end
end
