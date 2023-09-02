# frozen_string_literal: true

# $0 enc -aes-128-cbc -nosalt -K $key_hex -iv $iv_hex
Enc, cipher_ref, NoSalt, Key, key_hex, Iv, iv_hex, InQ, in_v = *ARGV

unless Enc == "enc" && NoSalt == "-nosalt" && Key == "-K" && (InQ.nil? || InQ == "-in")
  raise "Wrong args \"#{ARGV}\", expecting: enc -$cipher -nosalt -K $key_hex -iv $iv_hex [-in $file]"
end

md = /^-(.+)-cbc$/.match(cipher_ref)
raise "Bad cipher ref #{cipher_ref}" unless md

cipher_part_ref = md[1]

if cipher_part_ref == "bf"
  require "jdcrypt/blowfish"
  klass = JdCrypt::Blowfish
elsif cipher_part_ref =~ /^aes-/
  require "jdcrypt/aes"
  klass = JdCrypt::AES
else
  raise "Unknown cipher #{cipher_part_ref}"
end

key = [key_hex].pack("H*")
iv = [iv_hex].pack("H*")
require "./cbc"
plaintext =
  if InQ
    File.read(in_v)
  else
    $stdin.gets
  end
cipher = klass.new(key)
cbc = JdCrypt::CBC.new(cipher)
print cbc.encrypt(iv, plaintext)
