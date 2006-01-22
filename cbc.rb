class Crypt
    class CBC

        require "bytestream"    
        def CBC.pad_pkcs5(string, to_length) #:nodoc:
            diff= to_length - (string.length % to_length)
            string+=[diff].pack("C") * diff
            return string
        end
        
        def CBC.unpad_pkcs5(string) #:nodoc:
            return unless string.length > 0
            
            pad_len=string[-1]
            unless(string.slice!(-pad_len .. -1) == [pad_len].pack("C") * pad_len)
                raise "Unpad failure: trailing junk found"
            end
            return string
        end
        
        def initialize(cipher)
            @cipher=cipher
        end
        def encrypt(iv, plaintext)
            block_size=iv.length
                    
            last_block_e=ByteStream.new(iv)
            
            plaintext=CBC.pad_pkcs5(plaintext, iv.length)
            r_data="-" * plaintext.length
            
						j=0
						pt_l = plaintext.length
						while(j<pt_l)
                current_block=plaintext[j, block_size]
                to_encrypt=last_block_e^current_block
                last_block_e=ByteStream.new(@cipher.encrypt(to_encrypt))
                r_data[j, block_size]=last_block_e
								j+=block_size
            end
            return r_data
        end
        def decrypt(iv, ciphertext)
            block_size=iv.length
        
            last_block_e=ByteStream.new(iv)

            unless(ciphertext.length % block_size==0)
                raise "Bad IV: doesn't match ciphertext length"
            end
            
            r_data="-" * ciphertext.length
						j=0
						ct_l = ciphertext.length
						while(j<ct_l)
                current_block=ciphertext[j, block_size]

                pt_block=@cipher.decrypt(current_block)
                decrypted=last_block_e^pt_block
                last_block_e=ByteStream.new(current_block)
                r_data[j, block_size]=decrypted
								j+=block_size
            end
            r_data=CBC.unpad_pkcs5(r_data)
            return r_data
        end
    end
end
