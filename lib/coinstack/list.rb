require 'yaml'
require 'fileutils'
require 'securerandom'
require 'json'
require 'net/http'

module Coinstack
  # Object for reading and writing our list
  class List
    attr_accessor :pairs, # hash of hashes like { btc: {}, ltc: {} }
                  :user_pairs # hash like { btc: 12 } 

    PAIRS_URI = URI('https://api.coinmarketcap.com/v1/ticker/')
    DEFAULT_LOCATION = (File.dirname(__FILE__) + '/.coinstack-pairs').freeze

    def initialize
      self.pairs = {}
      update_pairs!
      FileUtils.touch(DEFAULT_LOCATION) # Ensures it exists
      self.user_pairs = YAML.load_file(DEFAULT_LOCATION) || {}
    end

    def update_pairs!
      res = Net::HTTP.get_response(PAIRS_URI)
      raise "Could not update pairs! #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      raw_array = JSON.parse(res.body)
      raw_array.each do |data|
        pairs[data['symbol']] = data
      end
    end

    def add(info)
      data = {}
      data[info[:symbol]] = info[:amount]
      user_pairs.merge!(data)
      save!
    end

    def remove(symbol)
      user_pairs.delete(symbol)
      save!
    end

    def save!
      File.open(DEFAULT_LOCATION, 'w') { |f| f.write user_pairs.to_yaml }
    end
  end

  # Object representing a single entry of the list
  class Pair
    attr_accessor :id,
                  :description,
                  :due_date,
                  :added_date,
                  :labels

    def initialize(options = {})
      options.each { |trait, value| public_send("#{trait}=", value) }
      self.labels ||= []
    end

    def to_s
      description.to_s.capitalize + " | Due: #{due_date}"
    end

    def to_h

    end
  end
end
