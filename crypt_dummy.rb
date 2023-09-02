# frozen_string_literal: true

require "jdcrypt/bytestream" unless defined? JdCrypt::ByteStream

class JdCrypt
  # Fake encrypter for testing
  class Dummy
    def initialize(encryption_key)
      @encryption_key = JdCrypt::ByteStream.new(encryption_key)
    end

    def block_sizes_supported
      [16]
    end

    def encrypt(plaintext)
      @encryption_key ^ plaintext
    end

    def decrypt(cyphertext)
      @encryption_key ^ cyphertext
    end
  end
end
