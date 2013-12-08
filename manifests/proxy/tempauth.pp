class swift::proxy::tempauth {

  $filter = 'filter:tempauth'

  swift_proxy_config {
    "${filter}/use": value  => 'egg:swift#tempauth';
  }
}
