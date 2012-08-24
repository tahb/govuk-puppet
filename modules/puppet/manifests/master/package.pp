class puppet::master::package {
  package { 'unicorn':
    provider => gem,
  }
  exec {'install rack 1.0.1':
    command => 'gem install rack --no-rdoc --no-ri --version 1.0.1',
    unless  => 'gem list | grep "rack.*1.0.1"'
  }
  package { 'puppetdb-terminus':
    ensure  => present,
  }
  file {'/var/run/puppetmaster':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
  }
  file { '/etc/init/puppetmaster.conf':
    content => template('puppet/etc/init/puppetmaster.conf.erb'),
  }
}
