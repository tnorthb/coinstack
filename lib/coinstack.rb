require 'coinstack/version'
require 'highline'
require 'coinstack/list'

module Coinstack
  # Defines functions the user directly interacts with.
  class Interface
    # TODO: Colorscheming, more prettifiers
    attr_accessor :list,
                  :cli
    def initialize
      self.list = List.new
      self.cli = HighLine.new
    end

    def start
      pretty_print_list if list.user_pairs.any?

      loop do
        cli.choose do |menu|
          menu.choice('Add an asset') { prompt_add_asset }
          menu.choice('Remove an asset') { prompt_remove_asset } # TODO
          menu.choice('Exit') { cli.say('Goodbye!') || exit }
        end
      end
    end

    def pretty_print_list
      total = 0
      data = []
      list.user_pairs.each do |symbol, amount|
        value = (list.pairs[symbol.to_s]['price_usd'].to_f * amount).round(2)
        data.push(symbol => value)
        total += value
      end

      cli.say('Your Portfolio:')
      data.push({}, { TOTAL: total.round(2).to_s }, {})
      pretty_print(data)
    end

    def prompt_add_asset
      to_add = { amount: nil, symbol: nil }

      loop do
        break if to_add[:symbol] == 'DONE'
        if list.pairs[to_add[:symbol]] && to_add[:amount]
          list.add(to_add)
          to_add = { amount: nil, symbol: nil }
        elsif list.pairs[to_add[:symbol]]
          to_add[:amount] = cli.ask("Type the amount of #{to_add[:symbol]} you have.", Float)
        else
          to_add[:symbol] = cli.ask('Type the symbol of the asset to add, or type "done"').upcase
        end
      end
      start
    end

    def prompt_remove_asset
      symbol = cli.ask('Which symbol would you like removed?').upcase
      list.remove(symbol)
      start
    end

    ROW_LENGTH = 24
    # Data should be an array of hashes,
    # data[0] gets printed first and so on
    def pretty_print(data)
      data.each do |datum|
        if datum.empty?
          cli.say('-' * ROW_LENGTH)
        else
          datum.each do |key, value|
            info_length = "#{key} #{value}".length
            buffer = ' ' * [ROW_LENGTH - info_length, 0].max
            row = key.to_s + buffer + '$' + value.to_s

            cli.say(row)
          end
        end
      end
    end
  end
end
