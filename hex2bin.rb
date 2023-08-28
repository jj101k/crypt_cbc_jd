#!/usr/bin/env ruby

# frozen_string_literal: true

to_encode = ARGV[0]
Encoded = to_encode.gsub(/[^0-9a-f]/i, "")
print [Encoded].pack("H*")
