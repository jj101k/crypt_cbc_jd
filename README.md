# JdCrypt::CBC

**Important note** You should probably use the OpenSSL module instead. It will
be significantly faster and more reliable

This provides CBC block-cipher-to-stream-cipher capability. If
you're using a block cipher like AES or Blowfish, you'll want
something like this to handle variable-length input.

## Usage

```ruby
require "jdcrypt/aes" # For example
require "jdcrypt/cbc"

cipher = JdCrypt::AES.new(key)
cbc = JdCrypt::CBC.new(cipher)
cbc.encrypt(iv, plaintext)
```

# FILES

crypt_dummy.rb
  - Helper class for testing. This does the simplest (and probably
    the worst for this purpose) encryption cipher: XOR.
test.rb
  - Test script. Usage: ruby test.rb
openssl_like.rb
  - Helper for testing. This behaves like command-line openssl,
    which makes it easy to see if JdCrypt::CBC is doing the wrong
    thing.
install.rb
  - Installs the module. Usage: ruby install.rb
mkrelease.sh
mktar.sh
  - Helpers to make releases. You don't need to touch these.
cbc.rb
  - The JdCrypt::CBC module which will be installed.

# NOTES

## COMPATIBILITY AND PERFORMANCE

Ruby 2.6: test.rb with JdCrypt::AES takes 0.06s

# COPYRIGHT

All files copyright 2005-2023 Jim Driscoll <jim.a.driscoll@gmail.com>,
see COPYING for details.
