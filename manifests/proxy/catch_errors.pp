#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include swift::proxy::catch_errors
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#

class swift::proxy::catch_errors {

  $filter = 'filter:catch_errors'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#catch_errors';
  }
}
