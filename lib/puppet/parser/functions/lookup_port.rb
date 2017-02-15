module Puppet::Parser::Functions
  newfunction(:lookup_port, :type => :rvalue) do |args|
    servers = args[0]
    matching = args[1]
    default_port = args[2] || 80

    i = 0
    servers.each do |server|
      if server == matching then
        return default_port + i
      end

      i += 1
    end

    raise Puppet::ParseError, "Matching server not found"
  end
end
