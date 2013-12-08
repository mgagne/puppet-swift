# [*swauth_endpoint*]
# [*swauth_super_admin_user*]
class swift::proxy::swauth (
  $swauth_endpoint        = '127.0.0.1',
  $swauth_super_admin_key = 'swauthkey',
  $package_ensure         = present
) {

  $filter = 'filter:swauth'

  package { 'python-swauth':
    ensure  => $package_ensure,
    before  => Package['swift-proxy'],
  }

  swift_proxy_config {
    "${filter}/use":                    value => 'egg:swift#swauth';
    "${filter}/swauth_endpoint":        value => $swauth_endpoint;
    "${filter}/swauth_super_admin_key": value => $swauth_super_admin_key;
  }
}
