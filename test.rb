require "crypt/rijndael"
require "crypt/cbc"
plaintext='12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa'
key='xxxxxxxxxxxxxxxx'
iv='yyyyyyyyyyyyyyyy'
cipher=Crypt::Rijndael.new(key)
chain_cipher=Crypt::CBC.new(cipher)

raise unless chain_cipher.encrypt(iv, plaintext) == cipher.encrypt_CBC(iv, plaintext)
ciphertext=chain_cipher.encrypt(iv, plaintext)

raise unless chain_cipher.decrypt(iv, ciphertext) == cipher.decrypt_CBC(iv, ciphertext)

puts "Success!"
