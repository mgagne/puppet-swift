#
# Configure ceilometer middleware for swift
#
# == Dependencies
#
# puppet-ceilometer (http://github.com/enovance/puppet-ceilometer)
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@enovance.com
#
# == Copyright
#
# Copyright 2013 eNovance licensing@enovance.com
#
class swift::proxy::ceilometer(
  $ensure = 'present'
) inherits swift {

  $filter = 'filter:ceilometer'

  User['swift'] {
    groups +> 'ceilometer',
  }

  swift_proxy_config {
    "${filter}/use": value  => 'egg:ceilometer#swift';
  }
}
