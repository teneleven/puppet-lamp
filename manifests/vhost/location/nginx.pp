define lamp::vhost::location::nginx (
  $path     = undef,
  $vhost    = undef,
  $engine   = undef,
  $index    = undef,
  $priority = 500,

  /* proxy requests to this proxy */
  $proxy  = undef,
  $proxy_match = undef,

  $match  = undef, /* what to match for location directive */
  $script = undef, /* script to forward all requests to */
  $listen = undef, /* fcgi listen address */

  $fcgi_config = {},
  $fcgi_raw    = undef,

  $custom_options = {},
) {

  include lamp::server::nginx

  if ($proxy and $path) {
    # need a duplicate location, since we're serving files from path
    ::nginx::resource::location { "${title}_proxy":
      location => $proxy_match ? {
        undef   => '/',
        default => $proxy_match,
      },
      proxy            => $proxy,
      proxy_set_header => $lamp::server::nginx::proxy_headers,
      vhost            => $vhost,
      priority         => $priority,
    }

    $proxy_options = {}
  } elsif ($proxy and $path == undef) {
    # if we only set $proxy and not $path, we need to pass the $proxy to our
    # nginx vhost below (otherwise it errors since it needs at least $path *or*
    # $proxy set)
    $proxy_options = { 'proxy' => $proxy, 'proxy_set_header' => $lamp::server::nginx::proxy_headers }
  }

  if ($index or $script or $engine == 'fcgi') {
    if ($script) {
      $try = any2array($script)
    } elsif ($engine == 'fcgi') {
      $try = ['$fastcgi_script_name']
    } elsif ($index) {
      $try = concat(['$uri'], any2array($index))
    }

    if (size($try) == 1) {
      $last_try = '=404'
    } else {
      $last_try = undef
    }

    $location_cfg = {
      'try_files' => join(
        concat($try.map |$file| {
          $file ? {
            /^(\$|\=)/ => $file,
            /^\//      => "${file}\$is_args\$args",
            default    => "/${file}\$is_args\$args",
          }
        }, $last_try)
      , ' ')
    }
  } else {
    $location_cfg = undef
  }

  if ($engine == 'fcgi') {
    $custom_cfg = merge($fcgi_config, {
      /* fixes nginx path_info bug: https://forum.nginx.org/read.php?2,238825,238860 */
      'fastcgi_param PATH_INFO' => '$path_info',
      'set $path_info' => '$fastcgi_path_info',
    })
  } else {
    $custom_cfg = $fcgi_config
  }

  if ($engine or $script) {
    $fastcgi = $listen ? {
      default => $listen,
      undef   => $lamp::params::fcgi_listen,
    }

    $fastcgi_param = {
      'SCRIPT_FILENAME' => $script ? {
        default => ($script =~ /^(\$|\/)/) ? {
          true  => "\$document_root$script",
          false => "\$document_root/${script}"
        },
        undef   => '$document_root$fastcgi_script_name',
      }
    }
  } else {
    $fastcgi       = undef
    $fastcgi_param = undef
  }

  create_resources('::nginx::resource::location', { $title => merge(
    {
      ensure      => present,
      vhost       => $vhost,
      index_files => $index,
      www_root    => $path,
      location    => $match ? {
        default   => ($match =~ /^~/) ? {
          true    => $match,
          false   => "~ ${match}",
        },
        undef     => '/',
      },
      priority    => $priority,

      fastcgi       => $fastcgi,
      fastcgi_param => $fastcgi_param,

      location_cfg_prepend => merge({
        fastcgi_buffers => '16 16k',
        fastcgi_buffer_size => '32k'
      }, $custom_cfg),
      location_cfg_append  => $location_cfg,

      raw_prepend          => $fcgi_raw,
    },
    $proxy_options,
    $custom_options
  )})

}
