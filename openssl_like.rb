class_file, class_constant_name, key_hex, iv_hex = *ARGV
require "crypt/" + class_file
klass = Crypt.const_get(class_constant_name)
key = [key_hex].pack("H*")
iv = [iv_hex].pack("H*")
require "./cbc"
plaintext=STDIN.gets
cipher = klass.new(key)
cbc = JdCrypt::CBC.new(cipher)
print cbc.encrypt(iv, plaintext)
