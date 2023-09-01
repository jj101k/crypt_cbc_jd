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
raise unless ciphertext

raise unless chain_cipher.decrypt(iv, ciphertext) == plaintext

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

  long_batch_plaintext = "1234567890abcdef1234567890abcdef1234567890abcdef"

  fake_result = run_bulk(fake_openssl, long_batch_plaintext)
  real_result = run_bulk(real_openssl, long_batch_plaintext)
  raise "#{fake_openssl} produced a mismatching result (lengths #{fake_result.length}/#{real_result.length}" if fake_result != real_result
end

tests_done = 0
if defined? JdCrypt::Blowfish
  tests_done += 1
  key_hex = "DB" * 16
  iv_hex = "00" * 8
  fake_openssl = "#{ENV["_"]} ./openssl_like.rb blowfish Blowfish #{key_hex} #{iv_hex}"
  real_openssl = "openssl enc -bf-cbc -K #{key_hex} -iv #{iv_hex}"
  compare(fake_openssl, real_openssl, plaintext)
end
if defined? JdCrypt::AES
  tests_done += 1
  key_hex = "DB" * 16
  iv_hex = "00" * 16
  fake_openssl = "#{ENV["_"]} ./openssl_like.rb aes AES #{key_hex} #{iv_hex}"
  real_openssl = "openssl enc -aes-128-cbc -nosalt -K #{key_hex} -iv #{iv_hex}"
  compare(fake_openssl, real_openssl, plaintext)
end

puts "No detectable block-encryption modules; skipping openssl tests" if tests_done.zero?