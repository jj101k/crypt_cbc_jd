require "crypt/rijndael"
plaintext='12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa'
key="x"*16
iv="y"*16
cipher=Crypt::Rijndael.new(key)
raise unless cipher.encrypt("1"*16)
require "./cbc"
chain_cipher=Crypt::CBC.new(cipher)

raise unless chain_cipher.encrypt(iv, plaintext) == cipher.encrypt_CBC(iv, plaintext)
ciphertext=chain_cipher.encrypt(iv, plaintext)

raise unless chain_cipher.decrypt(iv, ciphertext) == cipher.decrypt_CBC(iv, ciphertext)

puts "Success!"
