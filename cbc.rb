# frozen_string_literal: true

require "jdcrypt/bytestream" unless defined? JdCrypt::ByteStream
require "securerandom"

class JdCrypt
  # Performs cipher block chaining
  class CBC
    # YARV (1.9) compat
    Use_getbyte = "".respond_to?(:getbyte)

    def self.pad_pkcs5(string, to_length) # :nodoc:
      diff = to_length - (string.length % to_length)
      string += [diff].pack("C") * diff
      string
    end

    # Detect the longest block size for the cipher
    def longest_block_size
      throw :block_length_unknown unless @cipher.respond_to? :block_sizes_supported

      @cipher.block_sizes_supported.max
    end

    # Produces a secure random initialisation vector
    def random_iv(length = longest_block_size)
      SecureRandom.random_bytes(length)
    end

    def self.unpad_pkcs5(string) # :nodoc:
      return unless string.length.positive?

      pad_len =
        if Use_getbyte # 1.9 returns a string from []
          string.getbyte(-1)
        else
          string[-1]
        end

      raise "Unpad failure: trailing junk found" unless string.slice!(-pad_len..-1) == [pad_len].pack("C") * pad_len

      string
    end

    def initialize(cipher)
      @cipher = cipher
    end

    def encrypt_simple(plaintext)
      iv = random_iv
      [iv, encrypt(iv, plaintext)]
    end

    def encrypt(iv, plaintext)
      block_size = iv.length
      last_block_e = JdCrypt::ByteStream.new(iv)
      plaintext = CBC.pad_pkcs5(plaintext, iv.length)
      r_data = "-" * plaintext.length

      (0..plaintext.length - 1).step(block_size).each do |j|
        last_block_e[0, block_size] = @cipher.encrypt(last_block_e ^ plaintext[j, block_size])
        r_data[j, block_size] = last_block_e
      end
      r_data
    end

    def decrypt(iv, ciphertext)
      block_size = iv.length
      last_block_e = JdCrypt::ByteStream.new(iv)

      raise "Bad IV: doesn't match ciphertext length" unless (ciphertext.length % block_size).zero?

      r_data = "-" * ciphertext.length
      (0..ciphertext.length - 1).step(block_size).each do |j|
        current_block = ciphertext[j, block_size]

        r_data[j, block_size] = last_block_e ^ @cipher.decrypt(current_block)
        last_block_e[0, block_size] = current_block
      end
      CBC.unpad_pkcs5(r_data)
    end
  end
end
