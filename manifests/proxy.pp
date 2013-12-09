#
# TODO - assumes that proxy server is always a memcached server
#
# TODO - the full list of all things that can be configured is here
#  https://github.com/openstack/swift/tree/master/swift/common/middleware
#
# Installs and configures the swift proxy node.
#
# [*Parameters*]
#
# [*proxy_local_net_ip*] The address that the proxy will bind to.
#   Required.
# [*port*] The port to which the proxy server will bind.
#   Optional. Defaults to 8080.
# [*pipeline*] The list of elements of the swift proxy pipeline.
#   Currently supports healthcheck, cache, proxy-server, and
#   one of the following auth_types: tempauth, swauth, keystone.
#   Each of the specified elements also need to be declared externally
#   as a puppet class with the exception of proxy-server.
#   Optional. Defaults to ['healthcheck', 'cache', 'tempauth', 'proxy-server']
# [*workers*] Number of threads to process requests.
#  Optional. Defaults to the number of processors.
# [*allow_account_management*]
#   Rather or not requests through this proxy can create and
#   delete accounts. Optional. Defaults to true.
# [*account_autocreate*] Rather accounts should automatically be created.
#  Has to be set to true for tempauth. Optional. Defaults to true.
# [*package_ensure*] Ensure state of the swift proxy package.
#   Optional. Defaults to present.
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
class swift::proxy(
  $proxy_local_net_ip,
  $port           = 8080,
  $pipeline       = ['healthcheck', 'cache', 'tempauth', 'proxy-server'],
  $workers        = $::processorcount,
  $allow_account_management = true,
  $account_autocreate = true,
  $log_headers    = false,
  $log_udp_host   = '',
  $log_udp_port   = '',
  $log_address    = '/dev/log',
  $log_level      = 'INFO',
  $log_facility   = 'LOG_LOCAL1',
  $log_handoffs   = true,
  $package_ensure = 'present'
) {

  include swift::params

  validate_bool($account_autocreate)
  validate_bool($allow_account_management)
  validate_array($pipeline)

  if (member($pipeline, 'tempauth')) {
    $auth_type = 'tempauth'
  } elsif(member($pipeline, 'swauth')) {
    $auth_type = 'swauth'
  } elsif(member($pipeline, 'keystone')) {
    $auth_type = 'keystone'
  } else {
    warning('no auth type provided in the pipeline')
  }

  if (! member($pipeline, 'proxy-server')) {
    warning('pipeline parameter must contain proxy-server')
  }

  if ($auth_type == 'tempauth' and ! $account_autocreate ) {
    fail('account_autocreate must be set to true when auth_type is tempauth')
  }

  Package['swift-proxy'] -> Swift_proxy_config<||>
  Swift_proxy_config<||> ~> Service['swift-proxy']

  package { 'swift-proxy':
    ensure => $package_ensure,
    name   => $::swift::params::proxy_package_name,
  }

  service { 'swift-proxy':
    ensure    => running,
    name      => $::swift::params::proxy_service_name,
    enable    => true,
    provider  => $::swift::params::service_provider,
    hasstatus => true,
  }

  file { '/etc/swift/proxy-server.conf':
    ensure  => present,
    owner   => 'swift',
    group   => 'swift',
    mode    => '0660',
    require => Package['swift-proxy'],
  }

  $required_classes = split(
    inline_template(
      "<%=
          (@pipeline - ['proxy-server']).collect do |x|
            'swift::proxy::' + x.gsub('-', '_')
          end.join(',')
      %>"), ',')

  swift_proxy_config { 'pipeline:main/pipeline':
    value   => join($pipeline, ' '),
    # require classes for each of the elements of the pipeline
    # this is to ensure the user gets reasonable elements if he
    # does not specify the backends for every specified element of
    # the pipeline
    require => Class[$required_classes]
  }

  if $proxy_local_net_ip {
    swift_proxy_config { 'DEFAULT/bind_ip': value => $proxy_local_net_ip }
  } else {
    swift_proxy_config { 'DEFAULT/bind_ip': ensure => absent }
  }

  swift_proxy_config {
    'DEFAULT/bind_port': value => $port;
    'DEFAULT/workers':   value => $workers;
    # logging
    'DEFAULT/log_facility': value => $log_facility;
    'DEFAULT/log_level':    value => $log_level;
    'DEFAULT/log_headers':  value => $log_headers;
    'DEFAULT/log_address':  value => $log_address;
    # app:proxy-server
    'app:proxy-server/set log_facility':   value => $log_facility;
    'app:proxy-server/set log_level':      value => $log_level;
    'app:proxy-server/set log_address':    value => $log_address;
    'app:proxy-server/log_handoffs':       value => $log_handoffs;
    'app:proxy-server/account_autocreate': value => $account_autocreate;
    'app:proxy-server/allow_account_management': value => $allow_account_management;
  }

  if $log_udp_host {
    swift_proxy_config { 'DEFAULT/log_udp_host': value => $log_udp_host }
    if $log_udp_port {
      swift_proxy_config { 'DEFAULT/log_udp_port': value => $log_udp_port }
    } else {
      swift_proxy_config { 'DEFAULT/log_udp_port': ensure => absent }
    }
  } else {
    swift_proxy_config { 'DEFAULT/log_udp_host': ensure => absent }
    swift_proxy_config { 'DEFAULT/log_udp_port': ensure => absent }
  }
}
