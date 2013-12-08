#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include 'swift::proxy::staticweb'
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#

class swift::proxy::staticweb {

  $filter = 'filter:staticweb'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#staticweb';
  }
}
