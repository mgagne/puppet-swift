#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Tests for swift::proxy::bulk
#

require 'spec_helper'

describe 'swift::proxy::bulk' do

  let :default_params do
    { :max_containers_per_extraction => 10000,
      :max_failed_extractions        => 1000,
      :max_deletes_per_request       => 10000,
      :yield_frequency               => 60 }
  end

  let :params do
    {}
  end

  shared_examples_for 'configures bulk filter' do
    let :p do
      default_params.merge(params)
    end

    [ 'max_containers_per_extraction',
      'max_failed_extractions',
      'max_deletes_per_request',
      'yield_frequency'
    ].each do |config|
      it "configures #{config} of bulk filter" do
        should contain_swift_proxy_config(
          "filter:bulk/#{config}").with_value(p[config.to_sym])
      end
    end
  end

  context 'when using default parameters' do
    it_behaves_like 'configures bulk filter'
  end

  context 'when overriding default parameters' do
    before do
      params.merge!(
        :max_containers_per_extraction => 5000,
        :max_failed_extractions        => 500,
        :max_deletes_per_request       => 5000,
        :yield_frequency               => 10
      )
    end
    it_behaves_like 'configures bulk filter'
  end
end
