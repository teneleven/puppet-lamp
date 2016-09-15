define lamp::vhost::nginx (
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
  $custom_options  = {},

  /* raw custom vhost fragment */
  $custom_fragment = undef
) {

  /* OLD PARAMS: */
  /* $site                = $title, */
  /* $hosts               = 'test.example.com', */
  /* $listen_options      = undef, */
  /* $path                = "${teneleven::params::web_root}/${title}/${teneleven::params::web_suffix}", */
  /* $serve_php_files     = false, /1* mostly useful for simple php apps *1/ */
  /* $app                 = undef, /1* proxy all 404'ed requests to this php app *1/ */
  /* $proxy               = undef, /1* proxy all undefined requests to this uri/upstream *1/ */
  /* $resolver            = [],    /1* proxy resolver *1/ */
  /* $fcgi_host           = '127.0.0.1:9000', */
  /* $fcgi_socket         = undef, */
  /* $fcgi_app_root       = $teneleven::nginx::app_root, */
  /* $additional_apps     = {}, /1* additional fcgi definitions *1/ */
  /* $location_cfg_append = undef, */
  /* $locations           = {}, */
  /* $ssl                 = false, */
  /* $ssl_cert            = undef, */
  /* $ssl_key             = undef, */

  $try_files = any2array($index).map |$file| {
    "/${file}\$is_args\$args"
  }

  $location_cfg = merge({
    'try_files' => join(concat(
      ['$uri'],
      $try_files
    ), ' ')
  }, $location_cfg_append)

  /* TODO include in template */
  /* if ($fcgi_socket) { */
  /*   $real_fcgi_host = "unix:///${fcgi_socket}" */
  /* } else { */
  /*   $real_fcgi_host = $fcgi_host */
  /* } */

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

  /* TODO below this line */

  if ($app) {
    teneleven::nginx::fcgi { "${title}_app":
      site     => $title,
      path     => $path,
      host     => $real_fcgi_host,
      app      => $app,
      app_root => $fcgi_app_root,
    }
  }

  if ($serve_php_files) {
    /* handle *.php files */
    teneleven::nginx::fcgi { "${title}_php":
      site     => $title,
      path     => $path,
      location => '~ [^/]\.php(/|$)',
      host     => $real_fcgi_host,
      app_root => $fcgi_app_root,

      custom_cfg => {
        'fastcgi_split_path_info' => '^(.*.php)(.*)$',
        /* fixes nginx path_info bug: https://forum.nginx.org/read.php?2,238825,238860 */
        'fastcgi_param PATH_INFO' => '$path_info',
        'set $path_info' => '$fastcgi_path_info',
      },

      /* don't allow access if file doesn't exist */
      custom_raw => 'if (!-f $document_root$fastcgi_script_name) { return 404; }',
    }
  } else {
    if (!$proxy) {
      /* block access to *.php files */
      teneleven::nginx::fcgi { "${title}_php":
        site     => $title,
        path     => $path,
        host     => $real_fcgi_host,
        app_root => $fcgi_app_root,
        priority => 600,
        location => '~ [^/]\.php(/|$)',

        custom_cfg => {
          'deny' => 'all',
          'access_log' => 'off',
          'log_not_found' => 'off',
        }
      }
    }
  }

  create_resources('nginx::resource::location', $locations, {})
  create_resources('teneleven::nginx::fcgi',    $additional_apps, {})

}
