# Scl (Simple Crypto Library)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/scl`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scl

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

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Scl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/scl/blob/master/CODE_OF_CONDUCT.md).
