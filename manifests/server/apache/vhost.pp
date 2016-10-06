define lamp::server::apache::vhost (
  $priority = undef,
  $hosts    = [],
  $path     = undef,
  $index    = ['index.html', 'index.htm', 'index.php'],
  $port     = undef,
  $engine   = undef,

  $ssl      = false, /* true automatically sets port (if undef) */
  $ssl_key  = undef,
  $ssl_cert = undef,

  /* hash with keys: match => regex, listen => FCGI addr */
  $apps = {},

  /* TODO consolidate location syntax */
  $locations = {},

  $override = ['All'],
  $options  = ['Indexes', 'FollowSymLinks', 'MultiViews'],

  /* custom options passed directly to apache/nginx vhost */
  $custom_options = {},

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  include lamp::params

  contain lamp::server::apache

  contain apache::mod::rewrite

  if ($engine == 'php') {
    contain apache::mod::proxy
    contain apache::mod::proxy_fcgi

    $engine_match = '\\.php(/.*)?$'
  } else {
    $engine_match = undef
  }

  /* expand listen URL for apache-specific syntax */
  if ('unix:' in $lamp::params::fcgi_listen or 'fcgi:' in $lamp::params::fcgi_listen) {
    $engine_listen = "${lamp::params::fcgi_listen}"
  } else {
    $engine_listen = "fcgi://${lamp::params::fcgi_listen}"
  }

  /* setup apache vhost */
  create_resources('::apache::vhost', { "${title}" => merge(
    {
      servername     => any2array($hosts)[0],
      serveraliases  => any2array($hosts),
      docroot        => $path,
      directoryindex => join(any2array($index), ', '),
      docroot_owner  => $lamp::params::web_user,
      docroot_group  => $lamp::params::web_group,

      directories    => merge(
        /* default apache directory */
        {
          provider       => 'directory',
          path           => $path,
          options        => $options,
          allow_override => $override,
          directoryindex => join(any2array($index), ', '),
        },
        $locations
      ),

      port => $port ? {
        default => $port,
        undef   => $ssl ? {
          default => $lamp::params::http_port,
          true    => $lamp::params::https_port
        }
      },

      ssl      => $ssl,
      ssl_key  => $ssl_key,
      ssl_cert => $ssl_cert,
    },
    $custom_options,
    { custom_fragment => template('lamp/vhost/apache.erb') }
  ) })

}
