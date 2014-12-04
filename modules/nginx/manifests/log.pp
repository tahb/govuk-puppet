# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
define nginx::log (
  $logpath       = '/var/log/nginx',
  $logstream     = absent,
  $json          = false,
  $logname       = regsubst($name, '\.[^.]*$', ''),
  $statsd_metric = undef,
  $statsd_timers = [],
  $ensure        = 'present',
  ){

  # Log name should not be absolute. Use $logpath.
  validate_re($title, '^[^/]')

  validate_re($ensure, '^(present|absent)$', 'Invalid ensure value')

  $logstream_ensure = $ensure ? {
    'present' => $logstream,
    'absent'  => 'absent',
  }

  govuk::logstream { $name:
    ensure        => $logstream_ensure,
    logfile       => "${logpath}/${name}",
    tags          => ['nginx'],
    fields        => {'application' => $logname},
    json          => $json,
    statsd_metric => $statsd_metric,
    statsd_timers => $statsd_timers
  }

}
