#
# Configures the swift proxy memcache server
#
# [*memcache_servers*] A list of the memcache servers to be used. Entries
#  should be in the form host:port.
#
# == Dependencies
#
#   Class['memcached']
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
class swift::proxy::cache(
  $memcache_servers = ['127.0.0.1:11211']
) {

  $filter = 'filter:cache'

  # require the memcached class if its on the same machine
  if grep($memcache_servers, '^127\.0\.0\.1') {
    Class['memcached'] -> Class['swift::proxy::cache']
  }

  if is_array($memcache_servers) {
    $memcache_servers_real = join($memcache_servers, ',')
  } else {
    $memcache_servers_real = $memcache_servers
  }

  swift_proxy_config {
    "${filter}/use":              value  => 'egg:swift#memcache';
    "${filter}/memcache_servers": value  => $memcache_servers_real;
  }
}
