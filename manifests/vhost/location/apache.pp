define lamp::vhost::location::apache (
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

  # Configure the defaultness of a vhost
  $filename = regsubst($vhost, ' ', '_', 'G')
  $priority = getparam(Apache::Vhost[$vhost], 'priority')
  if (!empty($priority)) {
    $priority_real = "${priority}-"
  } elsif $priority == false {
    $priority_real = ''
  } elsif $default_vhost {
    $priority_real = '10-'
  } else {
    $priority_real = '25-'
  }

  if ($engine == 'php') {
    contain apache::mod::proxy
    contain apache::mod::proxy_fcgi

    $engine_match = $match ? {
      undef   => '\\.php(/.*)?$',
      default => $match,
    }
  } else {
    $engine_match = $match
  }

  /* expand listen URL for apache-specific syntax */
  if (empty($listen)) {
    if ('unix:' in $lamp::params::fcgi_listen or 'fcgi:' in $lamp::params::fcgi_listen) {
      $real_listen = "${lamp::params::fcgi_listen}"
    } else {
      $real_listen = "fcgi://${lamp::params::fcgi_listen}"
    }
  } else {
    if ('unix:' in $listen or 'fcgi:' in $listen) {
      $real_listen = "${listen}"
    } else {
      $real_listen = "fcgi://${listen}"
    }
  }

  if ($script) {
    $engine_listen = "${real_listen}/${script}"
  } elsif ($listen) {
    $engine_listen = $real_listen
  }

  if ($proxy or $script) {
    contain apache::mod::proxy
    contain apache::mod::proxy_http

    $proxy_match = $match

    concat::fragment { "${vhost}-${title}":
      target  => "${priority_real}${filename}.conf",
      order   => 60,
      content => template('lamp/vhost/apache.erb'),
    }
  } else {
    $_directories = [
      merge($lamp::params::default_apache_directory, {
        provider        => 'directory',
          /* undef   => 'directory', */
          /* /1* TODO fix proxy ? *1/ */
          /* default => 'proxy', */
        /* }, */
        path            => $real_path,
        directoryindex  => join(any2array($index), ', '),
        custom_fragment => template('lamp/vhost/apache.erb')
      }, $custom_options)
    ]

    concat::fragment { "${vhost}-${title}":
      target  => "${priority_real}${filename}.conf",
      order   => 60,
      content => template('apache/vhost/_directories.erb'),
    }
  }

}
