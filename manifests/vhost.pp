# Examples
# --------
#
# @example
#    centos_lemp::vhost {
#        site_conf => 'example.com',
#        site_template => 'centos_lemp/nginx.conf.default.erb',
#        server_names => ['example.com', 'www.example.com'],
#        root => '/var/www/example.com',
#        index => ['index.html', 'index.htm'],
#    }
class centos_lemp::vhost (
  $site_conf = undef,
  $server_names = [],
  $root = undef,
  $index = [],
  
) {
  file { "${root}":
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
  }
}
