class lamp::params (
  $web_user  = 'www-data',
  $web_group = 'www-data',
  $web_uid   = 33,
  $web_gid   = 33,

  $http_port  = 80,
  $https_port = 443,

  $default_vhost_server = 'apache',
  $default_vhost_engine = 'php',
  $default_db_server    = 'mysql',
  $db_root_password     = '123',

  /* if we use multiple vhost servers in 1 entry, we'll default to           */
  /* using the following server for the reverse-proxy (listening at port 80) */
  /* other servers will all listen in on http_port + index (81, 82, etc.)    */
  $default_proxy_server = 'nginx',
  $default_proxy_host   = 'http://127.0.0.1',

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
