class lamp::params (
  $web_user  = 'www-data',
  $web_group = 'www-data',
  $app_root  = '/var/www',

  $http_port  = 80,
  $https_port = 443,

  $default_vhost_server = 'apache',
  $default_vhost_engine = 'php',

  /* enable dev mode? */
  $dev       = false
) {
}
