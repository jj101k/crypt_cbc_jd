#!/usr/bin/env ruby
to_encode = ARGV[0]
Encoded = to_encode.gsub(/[^0-9a-f]/i, '')
print [Encoded].pack("H*")
