#
# Configure swift healthcheck.
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::proxy::healthcheck {

  $filter = 'filter:healthcheck'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#healthcheck';
  }
}
