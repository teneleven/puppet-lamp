# puppet-lamp

[![Build Status](https://travis-ci.org/teneleven/puppet-lamp.svg?branch=master)](https://travis-ci.org/teneleven/puppet-lamp)

This module adds the ability to configure LAMP and/or LEMP vhosts with a single
unified configuration.

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

By default, this will provision Nginx (listening to port 80) and reverse proxy
hosts "host_1.com" and "www.host_1.com" to Apache (listening to port 81). If
you just want 1 single web server, just specify a single "server" above. See
"params.pp" for some helpful defaults you can set, such as the default
webserver type and default proxy server.

# Installation

Puppetfile:

```Puppetfile
#!/usr/bin/env ruby

forge "https://forgeapi.puppetlabs.com"

mod 'lamp',
  :git => 'git@github.com:teneleven/puppet-lamp.git'
```

Then do `librarian-puppet install`.

# TODO

This module is far from complete. Pull requests for these features are welcome.

 - [ ] **Reverse proxy**:
    - [x] **Nginx reverse-proxy**
    - [ ] **lighttpd reverse-proxy**: Nginx development has stalled :(
    - [ ] **Apache reverse-proxy**: For simplicity, I've elected to focus on
      nginx reverse-proxying since it is by far the most performant method.
      However, some sites *might* still want Apache reverse-proxy
      functionality, so we should test & add this functionality.
    - [ ] **Default configuration**: We should have more control over the
      default reverse-proxy setup (when multiple webserver types are
      specified).
 - [ ] **Database engines**: In order to fully complete the module's acronym,
   we should enable configuration of some database engines & databases.
    - [ ] MySQL
    - [ ] MariaDB
    - [ ] PostgreSQL
    - [ ] MongoDB/Redis/other NoSQL database engines?
 - [ ] **Other web servers**: There *are* some other web servers out there.
    - [ ] lighttpd
    - [ ] Tomcat and/or Jetty
    - [ ] IIS
 - [ ] **Other scripting languages**: That start with P of course (kidding).
