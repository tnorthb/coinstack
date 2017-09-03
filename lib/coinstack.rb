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
      symbol = nil
      amount = nil

      loop do
        cli.say('That symbol is not available') if symbol && list.pairs[symbol].nil?
        if list.pairs[symbol] && amount
          list.add(symbol, amount)
          symbol = nil
          amount = nil
        elsif list.pairs[symbol]
          amount = cli.ask("Enter the amount of #{symbol} you have:", Float)
        else
          symbol = cli.ask('Enter a valid asset ticker symbol, or leave blank:', String).upcase
        end
        break if symbol == ''
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
