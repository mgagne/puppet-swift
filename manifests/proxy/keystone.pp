#
# This class can be sed to manage keystone middleware for swift proxy
#
# == Parameters
#  [operator_roles] a list of keystone roles a user must have to gain
#    access to Swift.
#    Optional. Dfeaults to ['admin', 'SwiftOperator']
#    Must be an array of strings
#  [is_admin] Set to true to allow users to set ACLs on their account.
#    Optional. Defaults to true.
#
# == Authors
#
#  Dan Bode dan@puppetlabs.com
#  Francois Charlier fcharlier@ploup.net
#

class swift::proxy::keystone(
  $operator_roles      = ['admin', 'SwiftOperator'],
  $is_admin            = true
) {

  $filter = 'filter:keystone'

  if is_array($operator_roles) {
    $operator_roles_real = join($operator_roles, ', ')
  } else {
    $operator_roles_real = $operator_roles
  }

  swift_proxy_config {
    "${filter}/use":            value  => 'egg:swift#keystoneauth';
    "${filter}/is_admin":       value  => $is_admin;
    "${filter}/operator_roles": value  => $operator_roles_real;
  }
}
