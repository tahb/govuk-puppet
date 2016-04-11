#
class mongodb::s3backup::backup (
  $username = 'govuk-backups',
  $backup_dir = '/var/lib/s3backup',
  $backup_server = 'localhost',
  $s3_bucket  = 'govuk-mongodb-backup-s3',
  $gpg_user = undef,
  $private_gpg_key = undef,
  $private_gpg_key_fingerprint = undef,
  ){

# create user
  user { $username:
    ensure     => 'present',
    home       => $backup_dir,
    managehome => true,
  }

# push script
  file { '/usr/local/bin/mongodb-backup-s3':
    ensure  => present,
    content => template('mongodb/mongodb-backup-s3.erb'),
    owner   => $username,
    group   => $username,
    mode    => '0755',
    require => User[$username],
  }

# push warapper script
  file { '/usr/local/bin/mongodb-backup-s3-wrapper':
    ensure  => present,
    content => template('mongodb/mongodb-backup-s3-wrapper.erb'),
    owner   => $username,
    group   => $username,
    mode    => '0755',
    require => User[$username],
  }

# gpg stuff
  validate_re($private_gpg_key_fingerprint, '^[[:alnum:]]{40}$', 'Must supply full GPG fingerprint')

  file { "${backup_dir}/.gnupg":
    ensure => directory,
    mode   => '0700',
    owner  => $username,
    group  => $username,
  }

  # This ensures that stuff can be encrypted without prompt
  file { "${backup_dir}/.gnupg/gpg.conf":
    ensure  => present,
    content => 'trust-model always',
    mode    => '0600',
    owner   => $username,
    group   => $username,
  }

  file { "${backup_dir}/.gnupg/${private_gpg_key_fingerprint}_secret_key.asc":
    ensure  => present,
    mode    => '0600',
    content => $private_gpg_key,
    owner   => $username,
    group   => $username,
  }

  exec { 'import_gpg_secret_key':
    command     => "gpg --batch --delete-secret-and-public-key ${private_gpg_key_fingerprint}; gpg --allow-secret-key-import --import ${backup_dir}/.gnupg/${private_gpg_key_fingerprint}_secret_key.asc",
    user        => $username,
    group       => $username,
    subscribe   => File["${backup_dir}/.gnupg/${private_gpg_key_fingerprint}_secret_key.asc"],
    refreshonly => true,
  }

}
