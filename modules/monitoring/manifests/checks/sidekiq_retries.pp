# == Class: monitoring::checks::sidekiq
#
# Nagios alerts for Sidekiq
#
# === Variables:
#
# [*apps*]
#   A hash of target, desc and optional warning/critical threshold,
#   keyed on check name.
#
# [*warning*]
#   A default warning value
#
# [*critical*]
#   A default critical value
#

class monitoring::checks::sidekiq_retries (
  $apps = {},
  $warning = '10',
  $critical = '20'
) {

  validate_hash($apps)

  $check_sidekiq_defaults = {
    'use'                 => 'govuk_normal_priority',
    'host_name'           => $::fqdn,
    'notes_url'           => monitoring_docs_url(sidekiq_retries),
    'notification_period' => 'inoffice',
    'warning'             => $warning,
    'critical'            => $critical,
  }

  create_resources('icinga::check::graphite', $apps, $check_sidekiq_defaults)

}
