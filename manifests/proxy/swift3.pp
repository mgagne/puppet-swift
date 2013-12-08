#
# Configure swift swift3.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#   Joe Topjian joe@topjian.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::swift3(
  $ensure = 'present'
) {

  include swift::params

  $filter = 'filter:swift3'

  package { 'swift-plugin-s3':
    ensure => $ensure,
    name   => $::swift::params::swift3,
  }

  swift_proxy_config {
    "${filter}/use": value => 'egg:swift#swift3';
  }
}
