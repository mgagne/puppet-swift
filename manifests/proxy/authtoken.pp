# == Class: swift::proxy::authtoken
#
# Manage keystone's authtoken middleware for swift proxy
#
# === Parameters
#
# [admin_token] Keystone admin token that can serve as a shared secret
#   for authenticating. If defined, it is used instead of a password auth.
#   Optional. Defaults to false.
# [admin_user] User used to authenticate service.
#   Optional. Defaults to admin
# [admin_tenant_name] Tenant used to authenticate service.
#   Optional. Defaults to openstack.
# [admin_password] Password used with user to authenticate service.
#   Optional. Defaults to ChangeMe.
# [delay_decision] Set to 1 to support token-less access (anonymous access,
#   tempurl, ...)
#   Optional, Defaults to 0
# [auth_host] Host providing the keystone service API endpoint. Optional.
#   Defaults to 127.0.0.1
# [auth_port] Port where keystone service is listening. Optional.
#   Defaults to 3557.
# [auth_protocol] Protocol to use to communicate with keystone. Optional.
#   Defaults to https.
# [auth_admin_prefix] path part of the auth url. Optional.
#   This allows admin auth URIs like http://host/keystone/admin/v2.0.
#   Defaults to false for empty. It defined, should be a string with a leading '/' and no trailing '/'.
# [auth_uri] The public auth url to redirect unauthenticated requests.
#   Defaults to false to be expanded to '${auth_protocol}://${auth_host}:5000'.
#   Should be set to your public keystone endpoint (without version).
# [signing_dir] The cache directory for signing certificates.
#   Defaults to '/var/cache/swift'
# [cache] the cache backend to use
#   Optional. Defaults to 'swift.cache'
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#

class swift::proxy::authtoken(
  $admin_user          = 'swift',
  $admin_tenant_name   = 'services',
  $admin_password      = 'password',
  $auth_host           = '127.0.0.1',
  $auth_port           = '35357',
  $auth_protocol       = 'http',
  $auth_admin_prefix   = false,
  $auth_uri            = false,
  $delay_auth_decision = 1,
  $admin_token         = false,
  $signing_dir         = '/var/cache/swift',
  $cache               = 'swift.cache'
) {

  $filter = 'filter:authtoken'

  if $auth_admin_prefix {
    validate_re($auth_admin_prefix, '^(/.+[^/])?$')
    swift_proxy_config { "${filter}/auth_admin_prefix": value => $auth_admin_prefix; }
  } else {
    swift_proxy_config { "${filter}/auth_admin_prefix": ensure => absent; }
  }

  if $auth_uri {
    $auth_uri_real = $auth_uri
  } else {
    $auth_uri_real = "${auth_protocol}://${auth_host}:5000"
  }

  if $admin_token {
    swift_proxy_config {
      "${filter}/admin_token":      value  => $admin_token;
      "${filter}/admin_tenant_name": ensure => absent;
      "${filter}/admin_user":        ensure => absent;
      "${filter}/admin_password":    ensure => absent;
    }
  } else {
    swift_proxy_config {
      "${filter}/admin_token":      ensure => absent;
      "${filter}/admin_tenant_name": value  => $admin_tenant_name;
      "${filter}/admin_user":        value  => $admin_user;
      "${filter}/admin_password":    value  => $admin_password;
    }

  }

  swift_proxy_config {
    "${filter}/paste.filter_factory":    value => 'keystoneclient.middleware.auth_token:filter_factory';
    "${filter}/log_name":                value => 'swift';
    "${filter}/auth_host":               value => $auth_host;
    "${filter}/auth_port":               value => $auth_port;
    "${filter}/auth_protocol":           value => $auth_protocol;
    "${filter}/auth_uri":                value => $auth_uri_real;
    "${filter}/delay_auth_decision":     value => $delay_auth_decision;
    "${filter}/cache":                   value => $cache;
    "${filter}/include_service_catalog": value => $include_service_catalog;
    "${filter}/signing_dir":             value => $signing_dir;
  }

  file { $signing_dir:
    ensure => directory,
    mode   => '0700',
    owner  => 'swift',
    group  => 'swift',
  }
}
