# Money Uphold Bank

A gem that calculates the exchange rate using published rates from https://uphold.com

To be used as an exchange rate provider for the [money gem](https://github.com/RubyMoney/money)

## Uphold API

```json
[{
  "ask": "1",
  "bid": "1",
  "currency": "BTC",
  "pair": "BTCBTC"
}, {
  "ask": "440.99",
  "bid": "440",
  "currency": "USD",
  "pair": "BTCUSD"
}]
```

Full description of the ticker endpoint: https://uphold.com/en/developer/api/documentation/#get-all-tickers
Full Uphold API specification: https://uphold.com/en/developer/api/documentation

## Features

* Calculates exchange rates based on the mid market price, as [specified by Uphold itself](https://support.uphold.com/hc/en-us/articles/203664225-How-does-Uphold-set-its-conversion-rates-)
* Supports all Uphold currencies, including Bitcoin, Litecoin, and Voxelus
* Caches API response for a customizable time

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'money-uphold-bank'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install money-uphold-bank

## Usage

```ruby
# Minimal requirements
require "money/bank/uphold"

bank = Money::Bank::Uphold.new

# (optional)
# Set the number of seconds after which the rates are automatically expired.
# By default, they expire every hour
bank.ttl_in_seconds = 3600

Money.default_bank = bank
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/subvisual/money-uphold-bank. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

