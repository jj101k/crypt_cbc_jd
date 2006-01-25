require "crypt/bytestream"
class Crypt
	class Dummy
		def initialize(encryption_key)
			@encryption_key=Crypt::ByteStream.new(encryption_key)
		end
		def encrypt(plaintext)
			@encryption_key^plaintext
		end
		def decrypt(cyphertext)
			@encryption_key^cyphertext
		end
	end
end
