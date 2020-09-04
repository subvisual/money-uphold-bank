require "money/bank/variable_exchange"
require "open-uri"

class Money
  module Bank
    class Uphold < Money::Bank::VariableExchange
      UPHOLD_TICKERS_BASE_URL = "https://api.uphold.com/v0/ticker/".freeze
      UPHOLD_BASE_CURRENCY = "USD".freeze

      # Seconds after which the current rates are automatically expired
      attr_accessor :ttl_in_seconds

      # Parsed UpholdBank result as a Hash
      attr_reader :tickers

      # Rates expiration time
      attr_reader :rates_expire_at

      def initialize(*args, &block)
        super
        self.ttl_in_seconds = 3600 # 1 hour
      end

      # Update all rates from UpholdBank JSON
      def update_rates
        # clear all existing rates, even inferred ones
        store.each_rate do |iso_from, iso_to, _rate|
          add_rate(iso_from, iso_to, nil)
        end
        exchange_rates.each do |ticker|
          add_exchange_rates_from_ticker(ticker)
        end
      end

      alias original_get_rate get_rate

      def get_rate(iso_from, iso_to, opts = {})
        update_rates_if_expired

        super || get_indirect_rate(iso_from, iso_to, opts)
      end

      # Set the base currency for all rates. By default, USD is used.
      # @example
      #   uphold.source = 'USD'
      #
      # @param value [String] Currency code, ISO 3166-1 alpha-3
      #
      # @return [String] chosen base currency
      def source=(value)
        @source = Money::Currency.find(value.to_s).iso_code
      end

      # Get the base currency for all rates. By default, USD is used.
      #
      # @return [String] base currency
      def source
        @source ||= UPHOLD_BASE_CURRENCY
      end

      private

      def get_indirect_rate(iso_from, iso_to, opts = {})
        return 1 if Currency.wrap(iso_from).iso_code == Currency.wrap(iso_to).iso_code

        rate_to_base = original_get_rate(iso_from, source, opts)
        rate_from_base = original_get_rate(source, iso_to, opts)

        return unless rate_to_base && rate_from_base

        rate = rate_to_base * rate_from_base

        add_rate(iso_from, iso_to, rate)
        add_rate(iso_to, iso_from, 1.0 / rate)

        rate
      end

      def add_exchange_rates_from_ticker(ticker)
        iso_from, iso_to = ticker["pair"].scan(/.{3}/)
        rate = (ticker["ask"].to_f + ticker["bid"].to_f) * 0.5

        return unless Money::Currency.find(iso_from) && Money::Currency.find(iso_to)

        add_rate(iso_from, iso_to, rate)
        add_rate(iso_to, iso_from, 1.0 / rate)
      end

      def update_rates_if_expired
        update_rates if rates_expired?
      end

      def rates_expired?
        return true unless rates_expire_at

        rates_expire_at <= Time.now
      end

      def exchange_rates
        raw_rates = JSON.parse(read_from_url)
        @rates_expire_at = Time.now + ttl_in_seconds
        raw_rates
      rescue JSON::ParserError
        []
      end

      def read_from_url
        open(source_url).read
      end

      def source_url
        URI.join(UPHOLD_TICKERS_BASE_URL, source)
      end
    end
  end
end
