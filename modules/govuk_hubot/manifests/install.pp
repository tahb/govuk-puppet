# == Class hubot::install
#
# This class is called from hubot for install.
#
class hubot::install {

  package { $::hubot::package_name:
    ensure => present,
  }
}
