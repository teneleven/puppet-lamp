define lamp::vhost::apache (
  $priority = undef,
  $hosts    = [],
  $path     = undef,
  $index    = ['index.html', 'index.htm', 'index.php'],
  $port     = undef,
  $engine   = undef,

  $ssl       = false, /* true automatically sets port (if undef) */
  $ssl_key   = undef,
  $ssl_chain = undef,

  /* custom options passed directly to apache/nginx vhost */
  $custom_options  = {
    override => ['All'],
    options  => ['Indexes', 'FollowSymLinks', 'MultiViews'],
  },

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  include lamp::params

  if ($engine == 'php') {
    class { 'apache::mod::proxy': }
    class { 'apache::mod::proxy_fcgi': }
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

  /* TODO only do once */
  /* if ($ssl) { */
  /*   apache::listen ( "${lamp::params::https_port}" ) */
  /* } */

}
