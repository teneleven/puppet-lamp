class lamp (
  $vhosts = {},
  $php    = {},
  $db     = {}
) inherits lamp::params {

  /* ensure web user/group are properly setup */
  ensure_resource('group', $web_group, {
    ensure => present,
    gid    => $web_gid
  })
  ensure_resource('user', $web_user, {
    ensure => present,
    gid    => $web_gid,
    uid    => $web_uid
  })

  $vhost_servers = $vhosts.map |$key,$vhost| {
    if ('server' in $vhost and $vhost['server'] != undef) {
      $vhost['server']
    } else {
      $lamp::params::default_vhost_server
    }
  }

  if ($lamp::params::default_proxy_server in $vhost_servers) {
    $servers = unique(concat(
      [$lamp::params::default_proxy_server],
      $vhost_servers
    ))
  } else {
    $servers = unique($vhost_servers)
  }

  $vhosts.each |$name, $vhost| {
    if ($vhost['server']) {
      $server = $vhost['server']
    } else {
      $server = $lamp::params::default_vhost_server
    }

    contain "lamp::server::${server}"

    if (count($servers) <= 1) {
      # use default port
      $port = undef
    } else {
      # TODO ssl port(s)?
      $port = lookup_port($servers, $server, $lamp::params::http_port)

      if ($server == $lamp::params::default_proxy_server) {
        # setup reverse-proxies
        # TODO do this out of loop
        $vhosts.each |$key,$proxied| {
          if ('server' in $proxied and $proxied['server']) {
            $proxied_server = $proxied['server']
          } else {
            $proxied_server = $lamp::params::default_vhost_server
          }

          if ($proxied_server != $lamp::params::default_proxy_server) {
            $proxied_port = lookup_port($servers, $proxied_server, $lamp::params::http_port)

            ensure_resource('lamp::vhost', "${name}-proxy-${proxied_server}", {
              server => $server,
              port   => $port,
              hosts  => $proxied['hosts'],
              proxy  => "${lamp::params::default_proxy_host}:${proxied_port}",
              site   => $name,
            })
          }
        }
      }
    }

    create_resources('lamp::vhost', { $name => merge(
      {
        engine => $lamp::params::default_vhost_engine,
        server => $lamp::params::default_vhost_server,
        port   => $port,
      },
      $vhost
    )})
  }

  if ($php) {
    create_resources('class', { 'lamp::php' => $php })
  }

  /* if ($db) { */
  /* } */

}
