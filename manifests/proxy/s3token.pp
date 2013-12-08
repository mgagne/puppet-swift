#
# Configure swift s3token.
#
# == Parameters
#  [auth_host] the keystone host
#   Optional. Defaults to 127.0.0.1
#  [auth_port] the Keystone client API port
#   Optional. Defaults to 5000
#  [auth_protocol] http or https
#   Optional. Defaults to http
#
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Francois Charlier fcharlier@ploup.net
#
# == Copyright
#
# Copyright 2012 eNovance licensing@enovance.com
#
class swift::proxy::s3token(
  $auth_host     = '127.0.0.1',
  $auth_port     = '35357',
  $auth_protocol = 'http'
) {

  include keystone::python

  $filter = 'filter:s3token'

  swift_proxy_config {
    "${filter}/use":           value  => 'egg:swift#s3token';
    "${filter}/auth_host":     value  => $auth_host;
    "${filter}/auth_port":     value  => $auth_port;
    "${filter}/auth_protocol": value  => $auth_protocol;
  }
}
