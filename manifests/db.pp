/**
 * Configure simple databases. Only does simple things like creating a user,
 * database, and password.
 */
define lamp::db (
  $database = $title,
  $users    = {},
  $server   = undef,
) {

  if (!is_hash($users)) {
    fail('Users must be hash (username: password or username: { ... })')
  }

  include lamp::params

  if ($server) {
    $real_server = $server
  } else {
    $real_server = $lamp::params::default_db_server
  }

  if ($real_server in ['mysql', 'mariadb']) {

    # ensure root password in .my.cnf set
    file { '/root/.my.cnf':
      content => template('lamp/my.cnf.erb')
    }

    $users.each |$username,$val| {
      if (is_hash($val)) {
        $user = $val
      } else {
        $user = { 'password' => $val }
      }

      File['/root/.my.cnf'] -> ::Mysql::Db["${database}_${username}"] -> Exec['rm my.cnf']

      create_resources('::mysql::db', { "${database}_${username}" => merge(
        {
          'dbname' => $database,
          'user'   => $username,
          'host'   => $lamp::params::default_db_host,
          'grant'  => ['ALL'],
        },
        $user,
        {
          # generate password using native hashing algorithm
          'password' => mysql_server_password($user['password'])
        }
      )})
    }

    # remove .my.cnf after database setup:
    exec { 'rm my.cnf':
      command => '/bin/rm /root/.my.cnf'
    }

  } else {
    fail("Invalid database server: ${real_server}")
  }

}
