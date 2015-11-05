# == Class hubot::service
#
# This class is meant to be called from hubot.
# It ensure the service is running.
#
class hubot::service {

  service { $::hubot::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
