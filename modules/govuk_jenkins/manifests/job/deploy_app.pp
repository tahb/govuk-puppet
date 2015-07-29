# == Class: govuk_jenkins::job::deploy_app
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
# === Parameters
#
# [*auth_token*]
#   Token which will allow this job to be triggered remotely
#
# [*ci_deploy_jenkins_api_key*]
#   API key to download build artefacts from CI servers
#
class govuk_jenkins::job::deploy_app (
  $auth_token = undef,
  $ci_deploy_jenkins_api_key = undef,
) {
  file { '/etc/jenkins_jobs/jobs/deploy_app.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/deploy_app.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}