define lamp::vhost (
  $server   = undef, /* one of lamp::vhost::* servers */
  $priority = undef,
  $site     = $title,

  $hosts    = ['default'],
  $path     = undef,
  $index    = ['index.html', 'index.htm', 'index.php'],
  $port     = undef,
  $engine   = undef,

  $ssl      = false, /* true automatically sets port (if undef) */
  $ssl_key  = undef,
  $ssl_cert = undef,

  /* proxy all requests to this proxy */
  $proxy       = undef,
  $proxy_match = undef,

  $locations = {},

  /* custom options passed directly to apache/nginx vhost */
  $custom_options = {},

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  include lamp::params

  if ($server == 'nginx') {
    $try_files = any2array($index).map |$file| {
      "/${file}\$is_args\$args"
    }

    $location_cfg = {
      'try_files' => join(concat(
        ['$uri'],
        $try_files
      ), ' ')
    }

    create_resources('lamp::vhost::nginx', { "${title}" => {
      path        => $path,
      engine      => $engine,
      locations   => $locations,
      proxy       => $proxy,
      proxy_match => $proxy_match,
      site        => $site,
      options     => merge({
        ensure              => present,
        index_files         => any2array($index),
        server_name         => any2array($hosts),
        www_root            => $path,
        location_cfg_append => $location_cfg,
        ssl                 => $ssl,
        ssl_cert            => $ssl_cert,
        ssl_key             => $ssl_key,
        raw_append          => $custom_fragment,

        listen_port => $port ? {
          default => $port,
          undef   => $ssl ? {
            default => $lamp::params::http_port,
            true    => $lamp::params::https_port
          }
        }
      }, $custom_options)
    }})
  } elsif ($server == 'apache') {
    create_resources('lamp::vhost::apache', { "${title}" => {
      path        => $path,
      engine      => $engine,
      locations   => $locations,
      proxy       => $proxy,
      proxy_match => $proxy_match,
      site        => $site,
      options     => merge({
        servername     => any2array($hosts)[0],
        serveraliases  => any2array($hosts),
        docroot        => $path,
        directoryindex => join(any2array($index), ', '),
        docroot_owner  => $lamp::params::web_user,
        docroot_group  => $lamp::params::web_group,

        directories    => [
          /* default apache directory */
          merge($lamp::params::default_apache_directory, {
            path           => $path,
            directoryindex => join(any2array($index), ', '),
          }),
        ],

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
      }, $custom_options)
    }})
  }

}
