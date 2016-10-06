class lamp::params (
  $web_user  = 'www-data',
  $web_group = 'www-data',
  $web_uid   = 33,
  $web_gid   = 33,

  $http_port  = 80,
  $https_port = 443,

  $default_vhost_server = 'apache',
  $default_vhost_engine = 'php',

  /* either host:port string OR unix:/var/socket/location */
  $fcgi_listen = '127.0.0.1:9000',

  /* enable dev mode? */
  $dev       = false,

  /* default apache directory options */
  $default_apache_directory = {
    provider       => 'directory',
    options        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
    allow_override => ['All'],
  },
) {}
