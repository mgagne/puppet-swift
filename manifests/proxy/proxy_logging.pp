#
# Configure swift proxy-logging.
#
# == Authors
#
#   Joe Topjian joe@topjian.net
#
class swift::proxy::proxy_logging {

  $filter = 'filter:proxy-logging'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#proxy_logging';
  }
}
