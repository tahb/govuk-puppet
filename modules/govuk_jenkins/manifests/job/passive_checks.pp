# == Class: govuk_jenkins::job::passive_checks
#
# Create two files on disk that can be parsed by jenkins-job-builder
#
# [*app_domain*]
#   Domain to be used in link to Jenkins job.
#
class govuk_jenkins::job::passive_checks (
  $app_domain = hiera('app_domain'),
  ) {
    file { '/etc/jenkins_jobs/jobs/success_passive_check.yaml':
      ensure  => present,
      content => template('govuk_jenkins/jobs/success_passive_check.yaml.erb'),
      notify  => Exec['jenkins_jobs_update'],
    }

    $success_passive_check_url = "https://deploy.${app_domain}/job/Success_Passive_Check"

    @@icinga::passive_check { "jenkins_job_success_${::hostname}":
      service_description => 'Jenkins Job Success',
      host_name           => $::fqdn,
      action_url          => $success_passive_check_url,
    }

    $failure_passive_check_url = "https://deploy.${app_domain}/job/Failure_Passive_Check"

    @@icinga::passive_check { "jenkins_job_failure_${::hostname}":
      service_description => 'Jenkins Job Failure',
      host_name           => $::fqdn,
      action_url          => $failure_passive_check_url,
    }

    file { '/etc/jenkins_jobs/jobs/failure_passive_check.yaml':
      ensure  => present,
      content => template('govuk_jenkins/jobs/failure_passive_check.yaml.erb'),
      notify  => Exec['jenkins_jobs_update'],
    }
  }
