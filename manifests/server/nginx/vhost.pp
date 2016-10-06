define lamp::server::nginx::vhost (
  $site   = $title, /* used as nginx identifier */
  $path   = undef,
  $engine = undef,

  /* nginx options */
  $options = {},

  /* hash with keys: match => regex, listen => FCGI addr */
  $apps = {},

  /* TODO consolidate location syntax */
  $locations = {},

  /* proxy all requests to this url */
  $proxy       = undef,
  $proxy_match = undef,
) {

  contain lamp::server::nginx

  create_resources('::nginx::resource::vhost', { "${title}" => $options })

  if ($proxy) {
    ::nginx::resource::location { "${title}_proxy":
      location => $proxy_match ? {
        undef   => '/',
        default => $proxy_match,
      },
      proxy            => $proxy,
      proxy_set_header => ['Host $host', 'X-Forwarded-For $remote_addr'],
      vhost            => $site,
    }
  } else {
    $proxy_location = undef
  }

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
    if (!$proxy) {
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
    }
  }

  create_resources('nginx::resource::location', $locations, {})

  $apps.each |$key, $app| {
    create_resources('lamp::server::nginx::app', { "${key}" => merge(
      { 'site' => $site },
      $app
    )})
  }

}
