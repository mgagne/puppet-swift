#
# Configure swift cache_errors.
#
# == Dependencies
#
# == Examples
#
#  include swift::proxy::formpost
#
# == Authors
#
#   Mehdi Abaakouk <sileht@sileht.net>
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#

class swift::proxy::formpost {

  $filter = 'filter:formpost'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#formpost';
  }
}
