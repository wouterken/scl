# Scl (Simple Crypto Library)

Scl is the Ruby *Simple Cryptography Library*. It comes with both a library for use in a Ruby codebase and a fully featured command line tool for all of your basic cryptography needs.

As anybody in the crypto-space knows using any cryptography library that has not been extensively audited and battle-tested in a security critical system is asking for trouble, hence:<br/>
**This library is intended for use in hobbyist projects or educational purposes. Use at own risk**

For much of its functionality it is simply a fairly thin wrapper over OpenSSL functions and primitives and therefore should be quite robust and performant. It couples this with a clean and easy to use API making it a fantastic tool to learn about what cryptography has to offer.

With learning in mind it covers some of the most widely used and exciting functionality offered to us by cryptography.

* [Diffie Hellman key-exchange](#diffie-hellman-key-exchange)
* [Public-key encryption (RSA)](#rsa-encryption)
* [Public-key verification (RSA)](#rsa-verification)
* [Shamirs secret sharing](#shamirs-secret-sharing)
* [AES Block Cipher Encryption](#aes-encryption)
* [HMAC and Digests](#hmac-and-digests)

This tool provides basic insight around what each of the above has to offer us, and how you might potentially use these in unison to offer secure and/or verifiable solutions. Each of the above modules can be used from the command line interface, or imported directly into your code

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scl

## Usage (per module)

### Diffie Hellman Key Exchange
#### What is it?
Diffie–Hellman key exchange (D–H) is a method of securely exchanging cryptographic keys over a public channel and was one of the first public-key protocols as originally conceptualized by Ralph Merkle and named after Whitfield Diffie and Martin Hellman.<sup>[[1]]</sup>

#### How do I use it?
##### CLI
##### Library
#### Why is it great?
* You can agree on a shared secret on a public-channel without exposing anything to an eavesdropper.
* This means you do not need to trust your communication channel for it to be effective! (You could securely communicate using snail mail, smoke signals, carrier pigeons) and as long as both parties to the transmission properly secure the generated private and shared keys of the exchange you can know your communication is secure and private
* You do not need to share any secrets to complete the exchange.
* You can negotitate a new secret per transmission for perfect forward secrecy

#### How does it work?

### RSA(Encryption)
#### What is it?
RSA can be used to encrypt and decrypt messages utilising public-key cryptography.

Public key cryptography, or asymmetrical cryptography, is any cryptographic system that uses pairs of keys: public keys which may be disseminated widely, and private keys which are known only to the owner. This accomplishes two functions: authentication, which is when the public key is used to verify that a holder of the paired private key sent the message, and encryption, whereby only the holder of the paired private key can decrypt the message encrypted with the public key.<sup>[[2]]</sup>

#### How do I use it?
##### CLI
##### Library
#### Why is it great?
* You can use your private key to prove a message came from you
* Anyone can use your public key to construct a message for your eyes only
* You can establish secure communications between two or more parties without the need to engage in a key-negotiation process
* See also RSA(Verification)

#### How does it work?

### RSA(Verification)
#### What is it?
RSA can be used to generate digital signatures for a message and to compare a given signature with one generated from a digital message.

A digital signature is a mathematical scheme for demonstrating the authenticity of digital messages or documents. A valid digital signature gives a recipient reason to believe that the message was created by a known sender (authentication), that the sender cannot deny having sent the message (non-repudiation), and that the message was not altered in transit (integrity)<sup>[[3]]</sup>
#### How do I use it?
##### CLI
##### Library
#### Why is it great?
* See also RSA(Encryption)
#### How does it work?

### Shamir's Secret Sharing
#### What is it?
#### How do I use it?
##### CLI
##### Library
#### Why is it great?
#### How does it work?

### AES Encryption
#### What is it?
#### How do I use it?
##### CLI
##### Library
#### Why is it great?
#### How does it work?

### HMAC and Digests
#### What is it?
#### How do I use it?
##### CLI
##### Library
#### Why is it great?
#### How does it work?

## CLI

SCL Comes with a command line interface that allows you to perform basic encryption, decryption and key generation and key negotiation operations.

Example usage:

```
RSA:
scl rsa generate # Generate an RSA key-pair > prints to stdout in base64
scl rsa generate --size=2048 --out=/tmp/keypair # Generate an RSA key-pair with size 2048 and
                                                                # output binary as binary encoded.
                                                                # Save to path /tmp/keypair

scl rsa verify  --pub-key=/tmp/keypair/rsa.pub /path/to/file "signature" # Verify the signature of a file using a public key
scl rsa sign    --priv-key=/tmp/keypair/rsa.priv  /path/to/file          # Generate a signature, outputs to stdout
scl rsa encrypt --key=/tmp/keypair/rsa.[priv|pub] /path/to/file          # Encrypt a file, output to stdout
scl rsa decrypt --key=/tmp/keypair/rsa.[priv|pub] /path/to/file          # Decrypt a file, output to stdout

encrypt and decrypt both accept optional --cipher-size/-cs arguments
All rsa actions accept --format/--input-format/--output-format -f/-if/-of arguments

DH:
scl dh ping                               # Start a diffie hellman key-generation
scl dh pong [der] [public-key]            # Complete side-1 of a diffie hellman key-generation
scl dh done [der] [public-key] [priv-key] # Complete side-2 of a diffie hellman key-generation

AES:
scl aes encrypt                    # Encrypt from stdin
scl aes encrypt [file]             # Encrypt from file
scl aes encrypt --key="abc" [file] # Enc
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Scl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/scl/blob/master/CODE_OF_CONDUCT.md).

[1]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[2]: https://en.wikipedia.org/wiki/Public-key_cryptography
[3]: https://en.wikipedia.org/wiki/Digital_signature