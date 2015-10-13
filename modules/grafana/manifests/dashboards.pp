# == Class: grafana::dashboards
#
# Set up monitoring dashboards for grafana.
#
# === Parameters
#
# [*app_domain*]
#   The suffix that applications use for their domain names.
#
# [*machine_suffix_metrics*]
#   The machine hostname suffix for Graphite metrics.
#
class grafana::dashboards (
  $app_domain = undef,
  $machine_suffix_metrics = undef,
) {
  validate_string($app_domain, $machine_suffix_metrics)

  $dashboard_directory = '/etc/grafana/dashboards'

  $app_domain_metrics = regsubst($app_domain, '\.', '_', 'G')

  file { $dashboard_directory:
    ensure  => directory,
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/grafana/dashboards',
  }

  $common_intervals = [
    'auto',
    '1s',
    '1m',
    '5m',
    '10m',
    '30m',
    '1h',
    '3h',
    '12h',
    '1d',
    '1w',
    '1y',
  ]

  $common_nav = [
    {
      'type' => 'timepicker',
      'collapse' => false,
      'notice' => false,
      'enable' => true,
      'status' => 'Stable',
      'time_options' => [
        '5m',
        '15m',
        '1h',
        '6h',
        '12h',
        '24h',
        '2d',
        '7d',
        '30d',
      ],
      'refresh_intervals' => [
        '5s',
        '10s',
        '30s',
        '1m',
        '5m',
        '15m',
        '30m',
        '1h',
        '2h',
        '1d',
      ],
      'now' => true,
    },
  ]

  $legend_options = {
    'show' => true,
    'values' => false,
    'min' => false,
    'max' => false,
    'current' => false,
    'total' => false,
    'avg' => false,
  }

  file {
    "${dashboard_directory}/2ndline_health.json": content => template('grafana/dashboards/2ndline_health.json.erb');
    "${dashboard_directory}/application_http_error_codes.json": content => template('grafana/dashboards/application_http_error_codes.json.erb');
    "${dashboard_directory}/application_health.json": content => template('grafana/dashboards/application_health.json.erb');
    "${dashboard_directory}/edge_health.json": content => template('grafana/dashboards/edge_health.json.erb');
    "${dashboard_directory}/origin_health.json": content => template('grafana/dashboards/origin_health.json.erb');
    "${dashboard_directory}/whitehall_health.json": content => template('grafana/dashboards/whitehall_health.json.erb');
  }
}
