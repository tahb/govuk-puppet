# == Class: monitoring::pagerduty_drill
#
# Set up a weekly check that PagerDuty is working.
#
# The cron resource removes the `pagerduty_drill` file.
# The file not existing triggers the Icinga alert
# which notifies PagerDuty and calls the on-call phone.
#
# === Parameters
#
# [*enabled*]
#   Should the PagerDuty drill be enabled?
#
class monitoring::pagerduty_drill (
  $enabled = false,
) {
  if $enabled {
    $filename = '/var/run/pagerduty_drill'

    cron { 'pagerduty_drill_remove':
      ensure  => present,
      user    => 'root',
      weekday => 'wednesday',
      hour    => 10,
      minute  => 0,
      command => "touch ${filename}",
    }

    cron { 'pagerduty_drill_reinstate':
      ensure  => present,
      user    => 'root',
      weekday => 'wednesday',
      hour    => 11,
      minute  => 15,
      command => "rm -f ${filename}",
    }

    @@icinga::check { "pagerduty_drill_file_removed_on_${::hostname}":
      check_command       => "check_nrpe!check_file_not_exists!${filename}",
      use                 => 'govuk_urgent_priority',
      service_description => 'PagerDuty dry run in progress',
      host_name           => $::fqdn,
      notes_url           => monitoring_docs_url(pagerduty-dry-run),
    }
  }
}
