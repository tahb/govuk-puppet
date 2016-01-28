# == Class: puppet::cronjob
#
# === Parameters
#
# [*enabled*]
#   Boolean indicating whether a cronjob should be set up.
#
class puppet::cronjob (
  $enabled = true,
) {
  validate_bool($enabled)

  if $enabled {
    $first = fqdn_rand(30)
    $second = $first + 30

    cron { 'puppet':
      ensure  => present,
      user    => 'root',
      minute  => [$first, $second],
      command => '/usr/local/bin/govuk_puppet',
      require => File['/usr/local/bin/govuk_puppet'],
    }
  }
}
