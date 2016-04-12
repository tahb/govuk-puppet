#
class mongodb::s3backup::backup(
  $dir = '/var/lib/s3backup',
  $private_gpg_key = undef,
  $private_gpg_key_fingerprint = undef,
  $s3_bucket  = 'govuk-mongodb-backup-s3',
  $server = 'localhost',
  $standalone  = False,
  $user = 'govuk-backups'
  ){

# create user
  user { $user:
    ensure     => 'present',
    managehome => true,
  }

# push script
  file { '/usr/local/bin/mongodb-backup-s3':
    ensure  => present,
    content => template('mongodb/mongodb-backup-s3.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => User[$user],
  }

# push wrapper script
  file { '/usr/local/bin/mongodb-backup-s3-wrapper':
    ensure  => present,
    content => template('mongodb/mongodb-backup-s3-wrapper.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => User[$user],
  }

# gpg stuff
  validate_re($private_gpg_key_fingerprint, '^[[:alnum:]]{40}$', 'Must supply full GPG fingerprint')

  file { "/home/${user}/.gnupg":
    ensure => directory,
    mode   => '0700',
    owner  => $user,
    group  => $user,
  }

  # This ensures that stuff can be encrypted without prompt
  file { "/home/${user}/.gnupg/gpg.conf":
    ensure  => present,
    content => 'trust-model always',
    mode    => '0600',
    owner   => $user,
    group   => $user,
  }

  file { "/home/${user}/.gnupg/${s3backup_private_gpg_key_fingerprint}_secret_key.asc":
    ensure  => present,
    mode    => '0600',
    content => $private_gpg_key,
    owner   => $user,
    group   => $user,
  }

  exec { 'import_gpg_secret_key':
    command     => "gpg --batch --delete-secret-and-public-key ${private_gpg_key_fingerprint}; gpg --allow-secret-key-import --import /home/${s3backup_user}/.gnupg/${s3backup_private_gpg_key_fingerprint}_secret_key.asc",
    user        => $user,
    group       => $user,
    subscribe   => File["/home/${user}/.gnupg/${s3backup_private_gpg_key_fingerprint}_secret_key.asc"],
    refreshonly => true,
  }

}
