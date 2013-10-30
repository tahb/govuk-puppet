class monitoring::client::apt {
  # Provides:
  # - `notify-reboot-required` which is referenced in the `postinst`
  #   of some packages in order to request that the system be rebooted at a
  #   convenient time. Required by the `check_reboot_required` alert, but
  #   still beneficial to have on nodes that aren't monitored by Nagios.
  # - `apt-check` which is called by the `check_apt_security_updates` alert.
  #   More reliable than the builtin Nagios plugin.
  package { 'update-notifier-common':
    ensure => present,
  }

  @icinga::nrpe_config { 'check_apt_security_updates':
    source => 'puppet:///modules/monitoring/etc/nagios/nrpe.d/check_apt_security_updates.cfg',
  }
  @icinga::plugin { 'check_apt_security_updates':
    source  => 'puppet:///modules/monitoring/usr/lib/nagios/plugins/check_apt_security_updates',
    require => Package['update-notifier-common'],
  }
  @@icinga::check { "check_apt_security_updates_${::hostname}":
    check_command              => 'check_nrpe!check_apt_security_updates!0',
    service_description        => 'outstanding security updates',
    host_name                  => $::fqdn,
    attempts_before_hard_state => 24, # Wait 24hrs to allow unattended-upgrades to run first
    check_interval             => 60,
  }

  @icinga::nrpe_config { 'check_reboot_required':
    source => 'puppet:///modules/monitoring/etc/nagios/nrpe.d/check_reboot_required.cfg',
  }
  @icinga::plugin { 'check_reboot_required':
    source  => 'puppet:///modules/monitoring/usr/lib/nagios/plugins/check_reboot_required',
    require => Package['update-notifier-common'],
  }
  @@icinga::check { "check_reboot_required_${::hostname}":
    check_command       => 'check_nrpe!check_reboot_required!30 0',
    service_description => 'reboot required by apt',
    host_name           => $::fqdn,
    notes_url           => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#reboot-required-by-apt',
  }
}
