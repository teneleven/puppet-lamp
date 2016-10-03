class lamp inherits lamp::params {

  $config = hiera_hash('lamp', {})

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

  $config['vhosts'].each |$name, $vhost| {
    if ($vhost['server']) {
      $server = $vhost['server']
    } else {
      $server = $lamp::params::default_vhost_server
    }

    create_resources("lamp::server::${server}::vhost", merge(
      { engine => $lamp::params::default_vhost_engine },
      $vhost
    ))
  }

  if ($config['php']) {
    create_resources('class', { 'lamp::php' => $config['php'] })
  }

  /* if ($config['db']) { */
  /* } */

}
