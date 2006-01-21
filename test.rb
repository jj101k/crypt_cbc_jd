require "crypt_dummy"
plaintext='12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa'
key="!"*16
iv="y"*16
cipher=Crypt::Dummy.new(key)
raise unless cipher.encrypt("1"*16)
require "./cbc"
chain_cipher=Crypt::CBC.new(cipher)

ciphertext=chain_cipher.encrypt(iv, plaintext)
raise unless ciphertext

raise unless chain_cipher.decrypt(iv, ciphertext) == plaintext

puts "Success!"
