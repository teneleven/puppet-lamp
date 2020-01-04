# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----

# ---- original file header ----
#
# @summary
#   Convert a plaintext password to a hashed password using the MySQL server native hashing algorithm.
#
#
Puppet::Functions.create_function(:'mysql_server_password') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    
    plain_password=args[0]
    password=`mysql --defaults-extra-file=/root/.my.cnf -e "SELECT PASSWORD(#{plain_password})" 2>&1 | tail -n1`

    if password and password[0] == '*'
      return password
    else
      return args[0]
    end
  
  end
end