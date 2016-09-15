class lamp inherits lamp::params {

  $config = hiera_hash('lamp', {})

  $config['vhosts'].each |$name, $vhost| {
    if ($vhost['server']) {
      $server = $vhost['server']
    } else {
      $server = $lamp::params::default_vhost_server
    }

    create_resources("lamp::vhost::${server}", merge(
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
