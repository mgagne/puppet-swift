#
# Configure swift ratelimit.
#
# See Swift's ratelimit documentation for more detail about the values.
#
# == Parameters
#  [clock_accuracy] The accuracy of swift proxy servers' clocks.
#   1000 is 1ms max difference. No rate should be higher than this.
#   Optional. Defaults to 1000
#  [max_sleep_time_seconds] Time before the app returns a 498 response.
#   Optional. Defaults to 60.
#  [log_sleep_time_seconds] if >0, enables logging of sleeps longer than
#   the value.
#   Optional. Defaults to 0.
#  [rate_buffer_seconds] Time in second the rate counter can skip.
#   Optional. Defaults to 5.
#  [account_ratelimit] if >0, limits PUT and DELETE requests to containers
#   Optional. Defaults to 0.
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
class swift::proxy::ratelimit(
  $clock_accuracy         = 1000,
  $max_sleep_time_seconds = 60,
  $log_sleep_time_seconds = 0,
  $rate_buffer_seconds    = 5,
  $account_ratelimit      = 0
) {

  $filter = 'filter:ratelimit'

  swift_proxy_config {
    "${filter}/use":                    value  => 'egg:swift#ratelimit';
    "${filter}/clock_accuracy":         value  => $clock_accuracy;
    "${filter}/max_sleep_time_seconds": value  => $max_sleep_time_seconds;
    "${filter}/log_sleep_time_seconds": value  => $log_sleep_time_seconds;
    "${filter}/rate_buffer_seconds":    value  => $rate_buffer_seconds;
    "${filter}/account_ratelimit":      value  => $account_ratelimit;
  }
}
