# frozen_string_literal: true

require "tempfile"
require "./crypt_dummy"
plaintext = "12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa"
key = "!" * 16
iv = "y" * 16
cipher = JdCrypt::Dummy.new(key)
raise unless cipher.encrypt("1" * 16)

require "./cbc"
chain_cipher = JdCrypt::CBC.new(cipher)

ciphertext = chain_cipher.encrypt(iv, plaintext)
raise "Can't encrypt" unless ciphertext

raise "Can't decrypt" unless chain_cipher.decrypt(iv, ciphertext) == plaintext

puts "Success!"

%w[blowfish rijndael aes].each do |file|
  require "jdcrypt/#{file}"
rescue LoadError
  # Will be checked below
end

def run_bulk(command, plaintext)
  # Rebuild this using mktemp
  max_blocks = 1_000_000
  file = Tempfile.new
  begin
    file.write(plaintext * max_blocks)

    full_command = "#{command} -in #{file.path}"

    puts "Bulk test: #{full_command}"
    before = Time.now
    result = IO.popen(full_command, mode: "r", encoding: Encoding::ASCII_8BIT) do |io|
      io.read.unpack("H*")
    end
    after = Time.now
    file.unlink
    puts "Took #{after - before}s (bulk = #{plaintext.length * max_blocks})"
    result
  rescue Error => e
    file.unlink
    raise e
  end
end

def compare(fake_openssl, real_openssl, plaintext)
  puts "Quick test: #{fake_openssl} vs #{real_openssl}"
  fake_result = IO.popen(fake_openssl, mode: "r+") do |io|
    io.write(plaintext)
    io.close_write
    io.read.unpack("H*")
  end
  real_result = IO.popen(real_openssl, mode: "r+") do |io|
    io.write(plaintext)
    io.close_write
    io.read.unpack("H*")
  end

  raise "#{fake_openssl} produced #{fake_result} not #{real_result}" if fake_result != real_result

  puts "Passed"

  long_batch_plaintext = "1234567890abcdef1234567890abcdef1234567890abcdef"

  fake_result = run_bulk(fake_openssl, long_batch_plaintext)
  real_result = run_bulk(real_openssl, long_batch_plaintext)
  raise "#{fake_openssl} produced a mismatching result (lengths #{fake_result.length}/#{real_result.length}" if fake_result != real_result
end

# Verifies that the cipher can properly decrypt what it encrypts
def verify_cipher(cipher, iv, plaintext)
  cbc = JdCrypt::CBC.new(cipher)
  raise "Cannot decrypt what we encrypt" unless plaintext == cbc.decrypt(iv, cbc.encrypt(iv, plaintext))

  riv, rct = cbc.encrypt_simple(plaintext)
  raise "Random IV is unchanged" if iv == riv
  raise "Cannot decrypt what we encrypt (random IV)" unless plaintext == cbc.decrypt(riv, rct)
end

# Provides all current cipher tests
def test_cipher_full(name, c, openssl_name, block_length, key_length)
  puts "Testing #{name}"

  plaintext = "12234567890dsgayufkgdadseluhkigfkukgkusdygfuewyetuygkuycvwegw,a3qwa"

  key_hex = "DB" * key_length
  iv_hex = "00" * block_length

  key = [key_hex].pack("H*")
  cipher = c.new(key)
  verify_cipher(cipher, [iv_hex].pack("H*"), plaintext)

  puts "Cipher verified; testing compatibility & speed"

  fake_openssl = "#{ENV["_"]} ./openssl_like.rb enc -#{openssl_name}-cbc -nosalt -K #{key_hex} -iv #{iv_hex}"
  real_openssl = "openssl enc -#{openssl_name}-cbc -nosalt -K #{key_hex} -iv #{iv_hex}"

  compare(fake_openssl, real_openssl, plaintext)

  puts "Tests complete for #{name}"
end

tests_done = 0

if defined? JdCrypt::Blowfish
  tests_done += 1
  test_cipher_full("Blowfish", JdCrypt::Blowfish, "bf", 8, 16)
end
if defined? JdCrypt::AES
  tests_done += 1
  test_cipher_full("AES (128)", JdCrypt::AES, "aes-128", 16, 16)
  test_cipher_full("AES (192)", JdCrypt::AES, "aes-192", 16, 24)
  test_cipher_full("AES (256)", JdCrypt::AES, "aes-256", 16, 32)
end

puts "No detectable block-encryption modules; skipping openssl tests" if tests_done.zero?