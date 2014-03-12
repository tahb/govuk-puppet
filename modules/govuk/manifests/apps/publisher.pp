class govuk::apps::publisher(
    $port = 3000,
    $nagios_data_importer_check = true,
    $enable_procfile_worker = false
  ) {

  govuk::app { 'publisher':
    app_type           => 'rack',
    port               => $port,
    vhost_ssl_only     => true,
    health_check_path  => '/',
    log_format_is_json => true,
    asset_pipeline     => true,
    deny_framing       => true,
  }

  $service_desc = 'publisher local authority data importer error'

  file { '/usr/local/bin/local_authority_import_check':
    ensure  => present,
    mode    => '0755',
    content => template('govuk/local_authority_import_check.erb'),
  }

  if str2bool($nagios_data_importer_check) {
    @@icinga::passive_check { "check-local-authority-data-importer-${::hostname}":
      service_description => $service_desc,
      host_name           => $::fqdn,
      freshness_threshold => 28 * (60 * 60),
    }
  }

  if $enable_procfile_worker {
    govuk::procfile::worker {'publisher': }
  }
}
