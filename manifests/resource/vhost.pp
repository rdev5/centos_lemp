# Examples
# --------
#
# @example
#    centos_lemp::resource::vhost {
#        site_conf => 'example.com.conf',
#        site_template => 'centos_lemp/nginx.conf.default.erb',
#        server_names => ['example.com', 'www.example.com'],
#        root => '/var/www/example.com',
#        index => ['index.html', 'index.htm'],
#    }
define centos_lemp::resource::vhost (
  $site_conf = undef,
  $site_template = undef,
  $server_names = [],
  $www_root = undef,
  $index = [],
  
) {
  file { "${www_root}":
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0755',
  }

  file { "/etc/nginx/sites-available/${site_conf}":
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => template("${site_template}"),
    notify => Service['nginx'],
  }
  
  file { "/etc/nginx/sites-enabled/${site_conf}":
    ensure => 'link',
    target => "/etc/nginx/sites-available/${site_conf}",
    notify => Service['nginx'],
  }
}
