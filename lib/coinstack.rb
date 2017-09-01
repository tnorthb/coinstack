require 'coinstack/version'
require 'highline'
require 'coinstack/list'
require 'coinstack/printer'

module Coinstack
  # Defines functions the user directly interacts with.
  class Interface
    # TODO: Colorscheming, more prettifiers
    attr_accessor :list,
                  :printer,
                  :cli
    def initialize
      Money.use_i18n = false
      self.list = List.new
      self.cli = HighLine.new
      self.printer = Printer.new
    end

    def start
      printer.clear_screen
      printer.pretty_print_user_list(list) if list.user_pairs.any?

      loop do
        cli.choose do |menu|
          menu.select_by = :index_or_name
          menu.choice(:add, help: 'Add an asset') { prompt_add_asset }
          menu.choice(:remove, help: 'Remove an asset') { prompt_remove_asset }
          menu.choice(:exit, help: 'Exit') do
            cli.say('Goodbye!')
            exit
          end
        end
      end
    end

    def prompt_add_asset
      to_add = { amount: nil, symbol: nil }

      loop do
        if list.pairs[to_add[:symbol]] && to_add[:amount]
          list.add(to_add)
          to_add = { amount: nil, symbol: nil }
        elsif list.pairs[to_add[:symbol]]
          to_add[:amount] = cli.ask("Enter the amount of #{to_add[:symbol]} you have.", Float)
        else
          to_add[:symbol] = cli.ask('Enter the symbol of the asset to add, or leave blank to exit', String).upcase
        end
        break if to_add[:symbol].nil?
      end
      start
    end

    def prompt_remove_asset
      symbol = cli.ask('Which symbol would you like removed?').upcase
      list.remove(symbol)
      start
    end
  end
end
