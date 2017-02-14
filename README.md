# puppet-lamp

This module adds the ability to configure LAMP and/or LEMP vhosts with a single unified configuration.

For example (hiera.yaml):

```yaml
lamp:
  php:
    extensions: ['curl', 'gd', 'mysql', 'zip']
    ini:
      upload_max_filesize: '100M'
      post_max_size: '100M'
      memory_limit: '512M'

  vhosts:
    www:
      server: apache
      priority: 10
      path: /var/www/html
    host_1:
      server: apache
      hosts: ['host_1.com', 'www.host_1.com']
      path: /var/www/host_1
    host_2:
      server: nginx
      hosts: ['host_2.com', 'www.host_2.com']
      path: /var/www/host_2
```

Then, in your puppet manifest:

```puppet
node default {
    $lamp = hiera_hash('lamp', {})
    if (!empty($lamp)) {
      create_resources('class', { '::lamp' => $lamp })
    }
}
```

# Installation

Puppetfile:

```Puppetfile
#!/usr/bin/env ruby

forge "https://forgeapi.puppetlabs.com"

mod 'lamp',
  :git => 'git@github.com:teneleven/puppet-lamp.git'
```

Then do `librarian-puppet install`.