define lamp::server::nginx::vhost (
  $site     = $title, /* used as nginx identifier */

  $priority = undef,
  $hosts    = ['default'],
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
  $custom_options  = {},

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  contain lamp::server::nginx

  $try_files = any2array($index).map |$file| {
    "/${file}\$is_args\$args"
  }

  $location_cfg = {
    'try_files' => join(concat(
      ['$uri'],
      $try_files
    ), ' ')
  }

  create_resources('::nginx::resource::vhost', { "${title}" => merge(
    {
      ensure              => present,
      index_files         => any2array($index),
      server_name         => any2array($hosts),
      www_root            => $path,
      location_cfg_append => $location_cfg,
      ssl                 => $ssl,
      ssl_cert            => $ssl_cert,
      ssl_key             => $ssl_key,
      raw_append          => $custom_fragment,

      /* TODO proxy */
      /* proxy               => $proxy, */
      /* proxy_set_header    => $proxy ? { */
      /*   undef   => [], */
      /*   default => ['Host $host', 'X-Forwarded-For $remote_addr'] */
      /* }, */
      /* resolver            => $resolver, */

      listen_port => $port ? {
        default => $port,
        undef   => $ssl ? {
          default => $lamp::params::http_port,
          true    => $lamp::params::https_port
        }
      }
    },
    $custom_options
  ) })

  if ($engine == 'php') {
    /* handle *.php files */
    lamp::server::nginx::app { "${title}_php":
      site     => $site,
      engine   => 'php',
      path     => $path,
      match    => '[^/]\.php(/|$)',
      listen   => $lamp::params::fcgi_listen
      /* app_root => $path */
    }
  } else {
    /* if (!$proxy) { */
      /* block access to *.php files */
      lamp::server::nginx::fcgi { "${title}_php":
        site     => $site,
        path     => $path,
        app_root => $path,
        priority => 600,
        location => '[^/]\.php(/|$)',

        custom_cfg => {
          'deny' => 'all',
          'access_log' => 'off',
          'log_not_found' => 'off',
        }
      }
    /* } */
  }

  create_resources('nginx::resource::location', $locations, {})

  $apps.each |$key, $app| {
    create_resources('lamp::server::nginx::app', { "${key}" => merge(
      { 'site' => $site },
      $app
    )})
  }

}
