# == Class: govuk::apps::mapit
##
# === Parameters
#
# [*enabled*]
#   Should the app exist?
#
# [*port*]
#   What port should the app run on?
#
class govuk::apps::mapit (
  $enabled = false,
  $port    = '3108',
) {
  if $enabled {
    govuk::app { 'mapit':
      app_type           => 'procfile',
      port               => $port,
      vhost_ssl_only     => true,
      health_check_path  => '/',
      log_format_is_json => false;
    }

    package {
      [
        # These three packages are recommended when installing geospatial
        # support for Django:
        # https://docs.djangoproject.com/en/1.8/ref/contrib/gis/install/geolibs/
        'binutils',
        'libproj-dev',
        'gdal-bin',
        # This is also needed to be able to install python GDAL packages:
        'libgdal-dev',
      ]:
      ensure => present,
    }
  }
}
