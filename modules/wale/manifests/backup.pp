# == Define: Govuk_postgresql::Wal_e::Backup
#
# Creates an offsite backup of a chosen PostgreSQL database
# to an S3 bucket using WAL-E:
# https://github.com/wal-e/wal-e
#
# === Parameters:
#
# [*aws_access_key_id*]
#   The AWS access ID for the user that is allowed to
#   access the S3 bucket.
#
# [*aws_secret_access_key*]
#   The AWS secret access key for the user that is allowed
#   to access the S3 bucket.
#
# [*s3_bucket_url*]
#   The unique address of the S3 bucket, in the format of:
#   s3://bucketaddress/directory/foo
#
# [*gpg_key_id*]
#   The GPG key ID for use when encrypting a backup. When this is declared then
#   backups will be compressed.
#
# [*hour*]
#   The hour the cron job runs for the daily base backup.
#   Default: 6
#
# [*minute*]
#   The minute the cron job runs for the daily base backup.
#   Default: 20
#
# [*db_dir*]
#   The database directory to backup. WAL-E does hot backups
#   so there should be no impact, and the default backups up
#   everything.
#   Default: /var/lib/postgresql/9.3/main
#
# [*user*]
#   The user that runs the backups, and ensure they exist.
#
define wal_e::backup (
  $aws_access_key_id,
  $aws_secret_access_key,
  $s3_bucket_url,
  $gpg_key_id,
  $hour = 6,
  $minute = 20,
  $db_dir = '/var/lib/postgresql/9.3/main',
  $user = 'govuk_wale_backup',
) {
  # Install the required packages
  include govuk_postgresql::wal_e::package

  user { $user:
    ensure => present,
    shell  => '/bin/false',
  }

  file { '/etc/wal-e/':
    ensure => directory,
    owner  => $user,
    group  => 'postgres',
  }

  # Create a separate directory for specific envvars
  file { "/etc/wal-e/${title}.env.d":
    ensure => directory,
    owner  => $user,
    group  => 'postgres',
  }

  file { "/etc/wal-e/env.d/AWS_SECRET_ACCESS_KEY":
    value => $aws_secret_access_key,
    owner  => $user,
    group  => 'postgres',
  }

  file { "/etc/wal-e/env.d/AWS_ACCESS_KEY_ID":
    value => $aws_access_key_id,
    owner  => $user,
    group  => 'postgres',
  }

  file { "/etc/wal-e/env.d/WALE_S3_PREFIX":
    value => $s3_bucket_url,
    owner  => $user,
    group  => 'postgres',
  }

  file { "/etc/wal-e/env.d/WALE_GPG_KEY_ID":
    value => $gpg_key_id,
    owner  => $user,
    group  => 'postgres',
  }

  # Daily base backup
  file { "/etc/cron.d/wal-e_postgres_backup_push_cron":
    ensure  => present,
    content => template('govuk_postgresql/etc/cron.d/wal-e_postgres_backup_push_cron.erb'),
    mode    => '0775',
  }

  file { "/usr/local/bin/wal-e_postgres_backup_push":
    ensure  => present,
    content => template('govuk_postgresql/usr/local/bin/wal-e_postgres_backup_push.erb'),
    mode    => '0775',
    require => Class['govuk_postgresql::wal_e::package'],
  }

  # Configuration for continuous archiving to S3
  postgresql::server::config_entry {
    'archive_mode':
      value => 'on';
    'archive_command':
      value => "envdir /etc/wal-e/env.d /usr/local/bin/wal-e wal-push %p";
    'archive_timeout':
      value => '60';
  }

}
