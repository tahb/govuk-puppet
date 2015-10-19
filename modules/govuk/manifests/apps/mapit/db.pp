# == Class: govuk::apps::mapit:db
#
# === Parameters
#
# [*password*]
#   The password for the database user.
#
class govuk::apps::mapit::db (
  $password,
) {

  class { 'postgresql::server::postgis': }

  govuk_postgresql::db { 'mapit':
    user       => 'mapit',
    password   => $password,
    extensions => ['plpgsql', 'postgis'],
    require    => Postgresql::Server::Postgis,
  }
}
