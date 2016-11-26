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
  $http_port = 80,
  $site_conf = undef,
  $site_template = undef,
  $server_names = [],
  $www_root = undef,
  $index = [],
  
  $ssl = "on",
  $ssl_port = 443,
  $ssl_certificate = undef,
  $ssl_certificate_key = undef,
  $ssl_session_cache = "shared:SSL:20m",
  $ssl_session_timeout = "180m",
  $ssl_protocols = "TLSv1 TLSv1.1 TLSv1.2",
  $ssl_prefer_server_ciphers = "on",
  $ssl_ciphers = "ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5",
  $ssl_dhparam = "/etc/ssl/certs/dhparam.pem",
  $ssl_dhsize = 2048,
  $ssl_sts_age = undef,
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
  
  if ($ssl_dhparam != undef) {
    exec { "${site_conf}::dhparam":
      command => "/usr/bin/openssl dhparam -out ${ssl_dhparam} ${ssl_dhsize}; chmod 0600 ${ssl_dhparam}",
      onlyif => "/usr/bin/test ! -e ${ssl_dhparam}",
    }
  }
}
