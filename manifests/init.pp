# Class: centos_lemp
# ===========================
#
# Installs LEMP stack on CentOS 7.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `mysql_root`
#  "The parameter mysql_root must be set by the External Node Classifier
#  to specify the root password which will be used for mysql_secure_installation.
#
# Examples
# --------
#
# @example
#    class { 'centos_lemp':
#        nginx_root => '/var/www/html',
#        nginx_template => 'centos_lemp/nginx.conf.erb',
#
#        mysql_root => 'CHANGETHIS',
#        mysql_secure_script => 'puppet:///modules/centos_lemp/secure-mysql.sh',
#    }
#
# Authors
# -------
#
# Matt Borja <matt.borja@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2016 Matt Borja
#
class centos_lemp (
  $nginx_root = '/var/www/html',
  $nginx_template = 'centos_lemp/nginx.conf.erb',
  $mysql_root = undef,
  $mysql_secure_script = 'puppet:///modules/centos_lemp/secure-mysql.sh',
) {
    # yum-pdate
    exec { 'yum-update':
      command => '/usr/bin/yum -y update',
    }

    # nginx
    package { 'epel-release':
      require => Exec['yum-update'],
      ensure => installed,
    }

    package { 'nginx':
      require => Package['epel-release'],
      ensure => installed,
    }

    file { '/etc/nginx/nginx.conf':
      ensure => file,
      owner => 'root',
      group => 'root',
      mode => '0644',
      content => template("${nginx_template}")
    }
    
    file { '/etc/nginx/sites-available':
      ensure => directory,
      owner => 'root',
      group => 'root',
      mode => '0755',
    }

    file { '/etc/nginx/sites-enabled':
      ensure => directory,
      owner => 'root',
      group => 'root',
      mode => '0755',
    }

    service { 'nginx':
      ensure => running,
      enable => true,
    }

    # mariadb
    package { 'mariadb-server':
      require => Exec['yum-update'],
      ensure => installed,
    }

    package { 'mariadb':
      require => Exec['yum-update'],
      ensure => installed,
    }

    # automate mysql_secure_installation
    # https://github.com/bertvv/scripts/blob/master/src/secure-mysql.sh
    file { '/tmp/.secure-mysql.sh':
      require => Package['mariadb'],
      ensure => 'file',
      source => "${mysql_secure_script}",
      checksum => 'md5',
      checksum_value => 'eb0781ba0f8cf161a7dd342a19edac86',
      path => '/tmp/.secure-mysql.sh',
      owner => 'root',
      group => 'root',
      mode => '0700',
      notify => Exec['invoke secure-mysql.sh'],
    }

    exec { 'invoke secure-mysql.sh':
      command => "/tmp/.secure-mysql.sh ${mysql_root}",
      refreshonly => true,
    }

    service { 'mariadb':
      ensure => running,
      enable => true,
    }

    # php
    package { 'php':
      require => Exec['yum-update'],
      ensure => installed,
    }

    file_line { 'cgi.fix_pathinfo (/etc/php.ini)':
      path  => '/etc/php.ini',
      line  => 'cgi.fix_pathinfo = 0',
      match => '^cgi\.fix_pathinfo\s*=\s*.+',
    }

    file_line { 'expose_php (/etc/php.ini)':
      path  => '/etc/php.ini',
      line  => 'expose_php = Off',
      match => '^expose_php\s*=\s*.+',
    }

    # php-mysql
    package { 'php-mysql':
      require => Exec['yum-update'],
      ensure => installed,
    }

    # php-fpm
    package { 'php-fpm':
      require => Exec['yum-update'],
      ensure => installed,
    }

    file_line { 'user (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'user = nginx',
      match => '^user = .+',
    }

    file_line { 'group (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'group = nginx',
      match => '^group = .+',
    }

    file_line { 'listen (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'listen = /var/run/php-fpm/php-fpm.sock',
      match => '^listen = .+',
    }

    file_line { 'listen.owner  (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'listen.owner = nginx',
      match => '^listen\.owner = .+',
    }

    file_line { 'listen.group  (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'listen.group = nginx',
      match => '^listen\.group = .+',
    }

    file_line { 'listen.mode (/etc/php-fpm.d/www.conf)':
      path  => '/etc/php-fpm.d/www.conf',
      line  => 'listen.mode = 0600',
      match => '^listen\.mode = .+',
      notify => Service['nginx'],
    }

    service { 'php-fpm':
      ensure => running,
      enable => true,
    }
}
