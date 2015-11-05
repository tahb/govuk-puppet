# Class: hubot
# ===========================
#
# Full description of class hubot here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class hubot (
  $package_name = $::hubot::params::package_name,
  $service_name = $::hubot::params::service_name,
) inherits ::hubot::params {

  # validate parameters here

  class { '::hubot::install': } ->
  class { '::hubot::config': } ~>
  class { '::hubot::service': } ->
  Class['::hubot']
}
