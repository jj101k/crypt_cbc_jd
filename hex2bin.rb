#!/usr/bin/env ruby
to_encode = ARGV[0]
to_encode.gsub!(/[^0-9a-f]/i, '')
print [to_encode].pack("H*")
