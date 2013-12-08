require 'spec_helper'

describe 'swift::proxy::ratelimit' do

  let :default_params do
    { :clock_accuracy         => 1000,
      :max_sleep_time_seconds => 60,
      :log_sleep_time_seconds => 0,
      :rate_buffer_seconds    => 5,
      :account_ratelimit      => 0 }
  end

  let :params do
    {}
  end

  shared_examples_for 'ratelimit filter' do
    let :p do
      default_params.merge(params)
    end

    it 'configures ratelimit filter' do
      should contain_swift_proxy_config(
          'filter:ratelimit/use').with_value('egg:swift#ratelimit')
    end

    [ 'clock_accuracy',
      'max_sleep_time_seconds',
      'log_sleep_time_seconds',
      'rate_buffer_seconds',
      'account_ratelimit'
    ].each do |config|
      it "configures #{config} of ratelimit filter" do
        should contain_swift_proxy_config(
          "filter:ratelimit/#{config}").with_value(p[config.to_sym])
      end
    end
  end

  context 'with default parameters' do
    it_behaves_like 'ratelimit filter'
  end

  context 'when overriding default parameters' do
    before do
      params.merge!(
        :clock_accuracy         => 9436,
        :max_sleep_time_seconds => 3600,
        :log_sleep_time_seconds => 42,
        :rate_buffer_seconds    => 51,
        :account_ratelimit      => 69
      )
    end

    it_behaves_like 'ratelimit filter'
  end
end
