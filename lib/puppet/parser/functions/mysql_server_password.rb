module Puppet::Parser::Functions
  newfunction(:mysql_server_password, :type => :rvalue, :doc => <<-EOS
Convert a plaintext password to a hashed password using the MySQL server native hashing algorithm.
EOS
  ) do |args|
    plain_password=args[0]
    password=`mysql --defaults-extra-file=/root/.my.cnf -e "SELECT PASSWORD(#{plain_password})" 2>&1 | tail -n1`

    if password and password[0] == '*'
      return password
    else
      return args[0]
    end
  end
end
