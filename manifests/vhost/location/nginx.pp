define lamp::vhost::location::nginx (
  $path   = undef,
  $vhost  = undef,
  $engine = undef,
  $index  = undef,

  $proxy  = undef, /* proxy all requests to this proxy */
  $match  = undef, /* what to match for location directive */
  $script = undef, /* script to forward all requests to */
  $listen = undef, /* fcgi listen address */

  $custom_options = {},
) {

  /* $real_index = $index ? { */
  /*   undef   => getparam(Lamp::Vhost[$vhost], 'index'), */
  /*   default => $index, */
  /* } */

  $real_path = $path ? {
    undef   => getparam(Lamp::Vhost[$vhost], 'path'),
    default => $path,
  }

  if ($index or $script) {
    if ($script) {
      $try = $script
    } else {
      $try = $index
    }

    $location_cfg = {
      'try_files' => join(concat(
        ['$uri'],
        any2array($try).map |$file| { "/${file}\$is_args\$args" }
      ), ' ')
    }
  } else {
    $location_cfg = undef
  }

  if ($engine == 'php') {
    $custom_cfg = {
      'fastcgi_split_path_info' => '^(.*\.php)(.*)$',
      /* fixes nginx path_info bug: https://forum.nginx.org/read.php?2,238825,238860 */
      'fastcgi_param PATH_INFO' => '$path_info',
      'set $path_info' => '$fastcgi_path_info',
    }

    /* don't allow access if file doesn't exist */
    $custom_raw = 'if (!-f $document_root$fastcgi_script_name) { return 404; }'
  } else {
    $custom_cfg = {}
    $custom_raw = undef
  }

  if ($engine or $script) {
    $fastcgi = $listen ? {
      default => $listen,
      undef   => $lamp::params::fcgi_listen,
    }

    $fastcgi_param = {
      'SCRIPT_FILENAME' => $script ? {
        default => ($script =~ /^\//) ? {
          true  => $script,
          false => "/\$document_root/${script}",
        },
        undef   => '/$document_root/$fastcgi_script_name',
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
      www_root    => $real_path,
      location    => $match ? {
        default   => ($match =~ /^~/) ? {
          true  => $match,
          false => "~ ${match}"
        },
        undef     => "~ ^/${script}(/|\$)"
      },
      /* priority        => $priority, */

      proxy    => $proxy,
      proxy_set_header => $proxy ? {
        undef   => undef,
        default => ['Host $host', 'X-Forwarded-For $remote_addr'],
      },

      fastcgi       => $fastcgi,
      fastcgi_param => $fastcgi_param,

      location_cfg_prepend => merge({
        fastcgi_buffers => '16 16k',
        fastcgi_buffer_size => '32k'
      }, $custom_cfg),
      location_cfg_append  => $location_cfg,

      raw_prepend          => $custom_raw,
    },
    $custom_options
  )})

}
