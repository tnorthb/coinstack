require 'yaml'
require 'fileutils'
require 'securerandom'
require 'json'
require 'net/http'
require 'money'

module Coinstack
  # Object for reading and writing the user's assets + market data
  class List
    attr_accessor :pairs, # hash of hashes like { btc: {}, ltc: {} }
                  :user_pairs # array of UserPair objects

    PAIRS_URI = URI('https://api.coinmarketcap.com/v1/ticker/')
    DEFAULT_LOCATION = (File.dirname(__FILE__) + '/.coinstack-pairs').freeze

    def initialize
      self.pairs = {}
      update_pairs!
      FileUtils.touch(DEFAULT_LOCATION) # Ensures it exists
      read_user_pairs!
    end

    def read_user_pairs!
      self.user_pairs = []
      saved_user_data.each do |symbol, amount|
        add(symbol, amount, save: false)
      end
    end

    def update_pairs!
      res = Net::HTTP.get_response(PAIRS_URI)
      raise "Could not update pairs! #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      raw_array = JSON.parse(res.body)
      raw_array.each do |data|
        pairs[data['symbol']] = data
      end
    end

    def add(symbol, amount, save: true)
      cmc_data = pairs[symbol]
      user_pair = UserPair.new(symbol, amount)
      user_pair.add_list_data(cmc_data)
      user_pairs.push(user_pair)
      save! if save
    end

    def remove(symbol)
      user_pairs.reject! { |up| up.symbol == symbol }
      save!
    end

    def save!
      saving_data = {}
      File.open(DEFAULT_LOCATION, 'w') do |f|
        user_pairs.each do |user_pair|
          saving_data[user_pair.symbol] = user_pair.amount
        end
        f.write saving_data.to_yaml
      end
    end

    def saved_user_data
      default = { 'BTC' => 10.00, 'ETH' => 1.00 } # some defaults to help me develop faster
      YAML.load_file(DEFAULT_LOCATION) || default
    end
  end

  # Object for interacting with CMC's data in the context of a user
  class UserPair
    attr_accessor :symbol,
                  :exchange_rate,
                  :amount,
                  :perchant_change_week,
                  :perchant_change_day

    def initialize(symbol, amount)
      self.symbol = symbol
      self.amount = amount
    end

    def valuation
      Money.from_amount(amount * exchange_rate, 'USD') # TODO, configurable currency
    end

    # Builds a UserPair given the related CMC data
    def add_list_data(data)
      raise symbol.to_s if data.nil?
      self.exchange_rate = data['price_usd'].to_f
      self.perchant_change_week = data['percent_change_7d'].to_f
      self.perchant_change_day = data['percent_change_24h'].to_f
    end
  end
end
