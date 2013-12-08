#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include swift::proxy::tempurl
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#

class swift::proxy::tempurl {

  $filter = 'filter:tempurl'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#tempurl';
  }
}
