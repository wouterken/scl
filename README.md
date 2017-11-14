# Scl (Simple Crypto Library)

[![scl](https://img.shields.io/badge/scl--green.svg)](https://github.com/wouterken/scl)
[![Gem Version](https://badge.fury.io/rb/scl.svg)](http://badge.fury.io/rb/scl)
[![Downloads](https://img.shields.io/gem/dt/scl/stable.svg)](https://img.shields.io/gem/dt/scl)

Scl is the Ruby *Simple Cryptography Library*. It comes with both a library for use in a Ruby codebase and a fully featured command line tool for all of your basic cryptography needs.

As anybody in the crypto space knows, using a cryptography library that has not been extensively audited and battle-tested in a security critical system is asking for trouble, hence:<br/>
**This library is intended for use in hobbyist projects or educational purposes. Use at own risk**

For much of its functionality the library is simply a fairly thin wrapper over OpenSSL functions and primitives and therefore should be quite robust and performant. It couples this with a clean and easy to use API, making it a fantastic tool to learn about what cryptography has to offer.

With learning in mind it covers some of the most widely used and exciting functionality offered to us by cryptography.

* [Diffie Hellman key-exchange](#diffie-hellman-key-exchange)
* [Public-key encryption (RSA)](#rsaencryption)
* [Public-key verification (RSA)](#rsaverification)
* [Shamirs secret sharing](#shamirs-secret-sharing)
* [AES Block Cipher Encryption](#aes-cbc-encryption)
* [HMAC and Digests](#hmac-and-digests)

This tool provides basic insight around what each of the above has to offer us and how you might potentially use these in unison to offer secure and/or verifiable solutions. Each of the above modules can be used from the command line interface or imported directly into your code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scl

If you have your Ruby installations `bin` directory added to your path you should now also have access to the `scl` executable. To verify, try and execute

`scl -h`

## Usage (per module)

### Diffie Hellman Key Exchange
#### What is it?
Diffie–Hellman key exchange (D–H) is a method of securely exchanging cryptographic keys over a public channel and was one of the first public-key protocols as originally conceptualized by Ralph Merkle and named after Whitfield Diffie and Martin Hellman.<sup>[[1]]</sup>

#### How do I use it?
##### CLI
```bash
# Help
scl dh -h
scl dh syn -h
scl dh ack -h
scl dh fin -h

syn. Step 1 of a diffie hellman exchange.
Generates a private and public key and der to be used to generate a symmetric key with a second party.

  e.g
    >> Using public key (Saves to [filename].enc by default, unless -o is used)
    scl dh syn
    scl dh syn -fbase64
    scl dh syn -o ./dhell

ack. Step 2 of a diffie hellman exchange.
Requires the public output of step 1 (The der and public key)
Generates a private and public key and der to be used to generate a symmetric key with a second party.

The output [output_file].key contains the secret key generated by the DH exchange.
The public output [output_file].dh2.pub must be passed back to the first party to complete the exchange
  e.g
    >> Using public key (Saves to [filename].enc by default, unless -o is used)
    scl dh ack ./dh-key-exchange.dh1.pub
    scl dh ack ./dhell.dh1.pub -o ./dhell


fin. Step 3 and final step of a diffie hellman exchange.
Requires the private output of step 1 (The der and private key) and the public key from step 2
Generates a secret key shared with the second party

The output [output_file].key contains the secret key generated by the DH exchange.

  e.g
    >> Using public key (Saves to [filename].enc by default, unless -o is used)
    scl dh fin ./dh-key-exchange.dh1.priv ./dh-key-exchange.dh2.pub
    scl dh fin ./dhell.dh1.priv ./dhell.dh2.pub -o ./dhell
```
##### Library
```ruby
dh1 = Scl::DH.new
dh2 = Scl::DH.new # Could be on a different machine
syn = dh1.syn
ack = dh2.ack(syn[:public])
key_1 = ack[:private][:shared_key]
fin = dh1.fin(ack[:public].merge(syn[:private]))
key_2 = fin[:private][:shared_key]
key_2 == key_1
```
#### Why is it great?
* You can agree on a shared secret on a public-channel without exposing anything to an eavesdropper.
* This means you do not need to trust your communication channel for it to be effective! (You could securely communicate using snail mail, smoke signals, carrier pigeons) and as long as both parties to the transmission properly secure the generated private and shared keys of the exchange you can know your communication is secure and private
* You do not need to share any secrets to complete the exchange.
* You can negotitate a new secret per transmission for perfect forward secrecy

### RSA(Encryption)
#### What is it?
RSA can be used to encrypt and decrypt messages utilising public-key cryptography.

Public key cryptography, or asymmetrical cryptography, is any cryptographic system that uses pairs of keys: public keys which may be disseminated widely, and private keys which are known only to the owner. This accomplishes two functions: authentication, which is when the public key is used to verify that a holder of the paired private key sent the message, and encryption, whereby only the holder of the paired private key can decrypt the message encrypted with the public key.<sup>[[2]]</sup>

#### How do I use it?
##### CLI

```bash
scl rsa generate -h
scl rsa encrypt -h
scl rsa decrypt -h

generate.
Usage: scl rsa generate (options)

Generates an RSA keypair
  e.g
    >> Generates a key-pair and prints to stdout
    $ scl rsa generate

    >> Generates a key-pair and saves to the filesystem
    $ scl rsa generate -o /path/to/file

encrypt.
Encrypts a file.
  e.g
    >> Using public key (Saves to [filename].enc by default, unless -o is used)
    scl rsa encrypt -p /path/to/public_key /path/to/file
    scl rsa encrypt --pub-key /path/to/public_key /path/to/file

    >> Using public key (Saves to [filename].enc by default, unless -o is used)
    scl rsa encrypt -Z /path/to/private_key /path/to/file
    scl rsa encrypt --priv-key /path/to/private_key /path/to/file

decrypt.
Decrypts a file.
  e.g
    >> Using public key (Writes to stdout unless -o is used)
    scl rsa decrypt -p /path/to/public_key /path/to/file.enc
    scl rsa decrypt --pub-key /path/to/public_key /path/to/file.enc

    >> Using public key (Writes to stdout unless -o is used)
    scl rsa decrypt -Z /path/to/private_key /path/to/file.enc
    scl rsa decrypt --priv-key /path/to/private_key /path/to/file.enc

```
##### Library
```ruby
key_pair = Scl::RSA.generate(1024)
signature = key_pair.private.sign('Some value')
key_pair.public.verify(signature, 'Other Value')
# => false
key_pair.public.verify(signature, 'Some value')
# => true

key_pair.save('/Users/pico/Desktop', 'keypair')
key_pair2 = Scl::RSA.new(file: '/Users/pico/Desktop/keypair') # loads [file].pub and/or [file].priv. Both keys do not need to be present
```
#### Why is it great?
* You can use your private key to prove a message came from you
* Anyone can use your public key to construct a message for your eyes only
* You can establish secure communications between two or more parties without the need to engage in a key-negotiation process
* See also RSA(Verification)

### RSA(Verification)
#### What is it?
RSA can be used to generate digital signatures for a message and to compare a given signature with one generated from a digital message.

A digital signature is a mathematical scheme for demonstrating the authenticity of digital messages or documents. A valid digital signature gives a recipient reason to believe that the message was created by a known sender (authentication), that the sender cannot deny having sent the message (non-repudiation), and that the message was not altered in transit (integrity)<sup>[[3]]</sup>
#### How do I use it?
##### CLI
```bash
scl rsa generate -h
scl rsa sign -h
scl rsa verify -h

generate.
Usage: scl rsa generate (options)

Generates an RSA keypair
  e.g
    >> Generates a key-pair and prints to stdout
    $ scl rsa generate

    >> Generates a key-pair and saves to the filesystem
    $ scl rsa generate -o /path/to/file

sign.
Usage: scl rsa sign (options)

Signs a file using an RSA private key.
This file can then be verified using the corresponding public-key or the same private-key
  e.g
    >> Sign [file] using private key
    $ scl rsa sign file -Z /path/to/private/key

verify.
Usage: scl rsa verify (options)

Verifies a file matches a signature for an RSA private key
Verification can be performed using the corresponding public-key or the same private-key that generated the signature
  e.g

    >> Verify [file] using public key
    $ scl rsa verify -p /path/to/private/key file file.sig
    $ scl rsa verify --pub-key /path/to/private/key file file.sig

    >> Verify [file] using private key
    $ scl rsa verify -Z /path/to/private/key file file.sig


```
##### Library
```ruby
key_pair = Scl::RSA.generate(1024)
encrypted = key_pair.public.encrypt('Some message')
decrypted = key_pair.private.decrypt(encrypted)
# => "Some Message"

key_pair.save('/Users/pico/Desktop', 'keypair')
key_pair2 = Scl::RSA.new(file: '/Users/pico/Desktop/keypair') # loads [file].pub and/or [file].priv. Both keys do not need to be present

```
#### Why is it great?
* See also RSA(Encryption)
#### How does it work?

### Shamir's Secret Sharing
#### What is it?
This algorithm is a form of secret sharing, where a secret is divided into parts, giving each participant its own unique part, where some of the parts or all of them are needed in order to reconstruct the secret.

Counting on all participants to combine the secret might be impractical, and therefore sometimes the threshold scheme is used where any <i>k</i> of the parts are sufficient to reconstruct the original secret. <sup>[[4]]</sup>
#### How do I use it?
##### CLI
```bash
scl generate -h
scl combine -h

generate.
Usage: scl sss generate (options)

generate. Generate a set of shares for a shared secret
Arguments are the total number of shares to generate, and the number of shares required to unlock
the secret.
  e.g
    scl sss generate -m 3 -n 5
    scl sss generate --min-shares=11 --num-shares=14 -o output_file

Large secrets are encoded using multiple blocks, which can create large shares.
An alternative, more space efficient approach to this is to encode a shorter key using secret sharing,
and to then encrypt the large secret using this key and a block-cipher


combine.
Usage: scl sss combine (options)

combine. Combines a set of shares for a shared secret
Expects as an argument a file of "
" separate secret shares
  e.g
    scl sss combine shares.txt
```
##### Library
```ruby
sss = Scl::SecretShare.new(3, 5) # generate 5 shares, of which 3
                                 # will be required to reconstruct the secret
message = "A super secret message"
shares = sss.generate(message)
Scl::SecretShare.combine(shares) == message
# => true
Scl::SecretShare.combine(shares.sample(3)) == message
# => true
Scl::SecretShare.combine(shares.sample(2)) == message
# => false
```
#### Why is it great?
Secret sharing algorithms like this have recently seen a surge in popularity due to their usage in multi-signature wallet implementations for various cryptocurrencies. In short, this algorithm allows you to secure a secret so that at least <i>K</i> participants are required to unlock it. This is in contrast to simply XORing secret keys which we can easily use to ensure every participant is required to unlock a secret.

### AES-CBC Encryption
#### What is it?
Aes is a specification for the encryption of electronic data established by the U.S. National Institute of Standards and Technology (NIST) in 2001.[7]

Cipher block chaining (CBC)  a block cipher mode of operation is an algorithm that uses a block cipher to provide an information service such as confidentiality or authenticity. A mode of operation describes how repeatedly to apply a cipher's single-block operation securely to transform amounts of data larger than a block. <sup>[[5]]</sup>
#### How do I use it?
##### CLI
```bash
scl aes ciphers -h
scl aes encrypt -h
scl aes decrypt -h

ciphers.
Usage: scl aes ciphers (options)

ciphers. Prints a list of supported ciphers

  e.g
    scl aes ciphers

encrypt.
Usage: scl aes encrypt (options)

encrypt. Encrypt a given file.
Can optionally be given an existing key, otherwise a unique one will be generated alongside
the cipher text.
  e.g
    scl aes encrypt somefile
    scl aes encrypt somefile -k somekey

decrypt.
Usage: scl aes decrypt (options)

decrypt. Decrypt a given file.
Must be given a key using -k/--key-path
  e.g
    scl aes decrypt somefile.enc -k somekey.key
    scl aes decrypt somefile.enc -k somekey.key -o output.txt
```
##### Library
```ruby
aes = Scl::AES.new
# => #<Scl::AES:0x007fcc53c90988 @block_cipher=:CBC, @block_size=256>
ciphertext, key, iv = aes.encrypt("Some content")
# => ["\xD8\xFD[\xE1O\xDF\xEE\xCAB\xC8\x02Fb\xC52\x86", "\"v\x99U\xD9\xE5\xF3\x10\e\a\xE0\xE9M\xA0\r\x87\xA5\xDC0\x18E\x91\xC5I\xBB\xB1x\xC9\xDD\a\xC8-", "Z\x98A\xE0\xA51\x17CV\x90\xF9\x95\xDEo2z"]
aes.decrypt(ciphertext, key, iv)
# => "Some content"
```
#### Why is it great?
Using a secure encryption standard with a block cipher mode of operation allows us to encrypt data that is larger than our block-size. You can use this in conjunction with keys generated using Diffie Hellman key exchange, RSA or keys protected using Shamirs Secret sharing to transmit large quantities of data without needing to send manage large keys of similar size.

### HMAC and Digests
#### What is it?
A cryptographic hash function, is a one-way function to generates a pseudo-unique fixed-size signature for a message.
The hash function is simply to verify but intractable to reverse, allowing it to be used to verify authenticity of the underlying message. A valid digital signature gives a recipient reason to believe that the message in question is the same as one seen by a known counter-party that publishes the signature alongside the message.

The use of the secret cryptographic key provides an additional level of protection over simply using a cryptographic hash
A keyed-hash message authentication code (HMAC) is a specific type of message authentication code (MAC) involving a cryptographic hash function and a secret cryptographic key. The function uses two passes of hash computation utilising the secret-key as a means for protection against length-extension attacks
#### How do I use it?
##### CLI
```bash
scl digest list        -h
scl digest sign        -h
scl digest verify      -h
scl digest hmac        -h
scl digest hmac_verify -h

list.
=======
Usage: scl digest list (options)

list. List supported hash algorithms
  e.g.
  scl digest list

sign.
======
Usage: scl digest sign (options)

sign. Signs a file using a support hash algorithm. Defaults to sha256
  e.g
    scl digest sign /path/to/file
    scl digest sign /path/to/file -o stdout
    scl digest sign /path/to/file -d sha512


verify.
=======
Usage: scl digest verify (options)

verify
  e.g.
    scl digest verify file signature
    scl digest verify file signature -d sha512

hmac.
=======
Usage: scl digest hmac (options)

hmac. Generates an HMAC for a file, can be given an optional key or alternately one will be
generated for you. Keep hold of this key for verifying signatures in the future
  e.g.
    scl hmac file            # Generates both a digest and a secure random key
    scl hmac file -k keyfile # Generates a digest using an existing key
    scl hmac file -d sha512  # Provide alternate digest algorithm

hmac_verify.
=======
Usage: scl digest hmac_verify (options)

hmac. Verifies the contents of a file match an HMAC signature (using a given key)
  e.g.
    scl hmac_verify file signature -k keyfile


```
##### Library
```ruby
Scl::Digest.digest('sha256', 'Sign here')
# Always the same
# => "aee6760ca427dd06f9622ef1f238bdd672bdfdf25f1aced851d3c2f80aa7e740"
digest1, key1 = Scl::Digest.hmac('sha256', 'Sign here')
# Always different
# => [digest, key]
digest2, key2 = Scl::Digest.hmac('sha256', 'Sign here', ke1)
digest2 == digest2
# => true
```
#### Why is it great?
* Cryptographic hash function - Prove that a message has not been tampered with since a signature was generated
* HMAC - Similar to the benefits of the hash function with the added protection against length-extension attacks

## CLI

SCL Comes with a command line interface that allows you to perform basic encryption, decryption, key generation and key negotiation operations. Specific examples of this functionality are documented above.
To learn more about the CLI use the in-built help functionality

```bash
scl -h                    # top level help
scl [module] -h           # Help on a specific module
scl [module] [command] -h # Help on a specific command for a module
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing
Run `rake test` from the repository root (Ensure you have performed a bundle install)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Scl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/scl/blob/master/CODE_OF_CONDUCT.md).

[1]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[2]: https://en.wikipedia.org/wiki/Public-key_cryptography
[3]: https://en.wikipedia.org/wiki/Digital_signature
[4]: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[5]: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation