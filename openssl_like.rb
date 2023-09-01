# frozen_string_literal: true

class_file, class_constant_name, key_hex, iv_hex, in_q, in_v = *ARGV
require "jdcrypt/#{class_file}"
klass = JdCrypt.const_get(class_constant_name)
key = [key_hex].pack("H*")
iv = [iv_hex].pack("H*")
require "./cbc"
plaintext =
  if in_q == "-in"
    File.read(in_v)
  else
    $stdin.gets
  end
cipher = klass.new(key)
cbc = JdCrypt::CBC.new(cipher)
print cbc.encrypt(iv, plaintext)
