define lamp::server::apache::vhost (
  $priority = undef,
  $hosts    = [],
  $path     = undef,
  $index    = ['index.html', 'index.htm', 'index.php'],
  $port     = undef,
  $engine   = undef,

  $ssl       = false, /* true automatically sets port (if undef) */
  $ssl_key   = undef,
  $ssl_chain = undef,

  /* hash with keys: match => regex, listen => FCGI addr */
  $apps = {},

  /* TODO consolidate location syntax */
  $locations = {},

  /* custom options passed directly to apache/nginx vhost */
  $custom_options = {
    override => ['All'],
    options  => ['Indexes', 'FollowSymLinks', 'MultiViews'],
  },

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  include lamp::params

  if ($engine == 'php') {
    contain apache::mod::proxy
    contain apache::mod::proxy_fcgi

    $engine_match = '\\.php$'
  } else {
    $engine_match = undef
  }

  /* expand listen URL for apache-specific syntax */
  if ('unix:' in $lamp::params::fcgi_listen or 'fcgi:' in $lamp::params::fcgi_listen) {
    $engine_listen = $lamp::params::fcgi_listen
  } else {
    $engine_listen = "fcgi://${lamp::params::fcgi_listen}"
  }

  /* setup apache vhost */
  create_resources('apache::vhost', { "${title}" => merge(
    {
      servername     => any2array($hosts)[0],
      serveraliases  => any2array($hosts),
      docroot        => $path,
      directoryindex => join(any2array($index), ', '),
      docroot_owner  => $lamp::params::web_user,
      docroot_group  => $lamp::params::web_group,

      /* TODO perhaps just do this as part of template ? */
      directories    => $locations,

      port => $port ? {
        default => $port,
        undef   => $ssl ? {
          default => $lamp::params::http_port,
          true    => $lamp::params::https_port
        }
      }
    },
    $custom_options,
    { custom_fragment => template('vhost/apache.erb') }
  ) })

}
