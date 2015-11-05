# == Class hubot::params
#
# This class is meant to be called from hubot.
# It sets variables according to platform.
#
class hubot::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'hubot'
      $service_name = 'hubot'
    }
    'RedHat', 'Amazon': {
      $package_name = 'hubot'
      $service_name = 'hubot'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
