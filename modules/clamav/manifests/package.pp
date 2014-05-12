class clamav::package (
    $use_service
  ) {
  package { ['clamav', 'clamav-freshclam', 'clamav-daemon']:
    ensure  => 'latest',
  }

  if $use_service {
    $symlink_target = '/usr/bin/clamscan'
  } else {
    $symlink_target = '/usr/bin/clamdscan'
  }

  file { '/usr/local/bin/govuk_clamscan':
    ensure  => symlink,
    target  => $symlink_target,
    require => Package['clamav'],
  }
}
