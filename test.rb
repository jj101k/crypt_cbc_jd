# frozen_string_literal: true

require "./crypt_dummy"
plaintext = "12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa"
key = "!" * 16
iv = "y" * 16
cipher = JdCrypt::Dummy.new(key)
raise unless cipher.encrypt("1" * 16)

require "./cbc"
chain_cipher = JdCrypt::CBC.new(cipher)

ciphertext = chain_cipher.encrypt(iv, plaintext)
raise unless ciphertext

raise unless chain_cipher.decrypt(iv, ciphertext) == plaintext

puts "Success!"

puts "Now performing nice visual comparison (if this mismatches, there's a problem)"
plaintext_hex = "4f682c20746865206772616e64206f6c642044756b65206f6620596f726b"

%w[blowfish rijndael aes].each do |file|
  require "jdcrypt/#{file}"
rescue LoadError
  # Will be checked below
end

tests_done = 0
if defined? JdCrypt::Blowfish
  tests_done += 1
  key_hex = "DB" * 16
  iv_hex = "00" * 8
  fake_openssl = "./hex2bin.rb #{plaintext_hex} | #{ENV["_"]} ./openssl_like.rb blowfish Blowfish #{key_hex} #{iv_hex} \
    | ./bin2hex.rb"
  real_openssl = "./hex2bin.rb #{plaintext_hex} | openssl bf-cbc -nosalt -K #{key_hex} -iv #{iv_hex} | ./bin2hex.rb"
  puts fake_openssl
  system(fake_openssl)
  puts real_openssl
  system(fake_openssl)
end
if defined? JdCrypt::AES
  tests_done += 1
  key_hex = "DB" * 16
  iv_hex = "00" * 16
  fake_openssl = "./hex2bin.rb #{plaintext_hex} | #{ENV["_"]} ./openssl_like.rb aes AES #{key_hex} #{iv_hex} \
    | ./bin2hex.rb"
  real_openssl = "./hex2bin.rb #{plaintext_hex} | openssl bf-cbc -nosalt -K #{key_hex} -iv #{iv_hex} | ./bin2hex.rb"
  puts fake_openssl
  system(fake_openssl)
  puts real_openssl
  system(fake_openssl)
end

puts "No detectable block-encryption modules; skipping openssl tests" if tests_done.zero?