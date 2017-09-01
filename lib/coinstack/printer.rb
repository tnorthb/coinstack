require 'money'

module Coinstack
  # Formats and delivers data for the screeen
  class Printer
    attr_accessor :currency,
                  :cli

    ROW_LENGTH = 24

    def initialize
      self.cli = HighLine.new
      self.currency = 'USD'
    end

    # Prints out a summary of the user's hodlings formatted nicely
    def pretty_print_user_list(list)
      total = 0
      data = []
      list.user_pairs.each do |symbol, amount|
        whole_value = list.pairs[symbol.to_s]['price_usd'].to_f * amount
        value = Money.from_amount(whole_value, currency)
        data.push(symbol => value.format)
        total += value
      end

      cli.say('Your Portfolio:')
      data.push({}, { TOTAL: total.format }, {})
      print_hashes(data)
    end

    # Data should be an array of hashes,
    # data[0] gets printed first and so on
    def print_hashes(data)
      data.each do |datum|
        if datum.empty?
          cli.say('-' * ROW_LENGTH)
        else
          datum.each do |key, value|
            info_length = "#{key}#{value}".length
            buffer = ' ' * [ROW_LENGTH - info_length, 0].max
            row = key.to_s + buffer + value.to_s

            cli.say(row)
          end
        end
      end
    end

    def clear_screen
      Gem.win_platform? ? (system 'cls') : (system 'clear')
    end
  end
end
