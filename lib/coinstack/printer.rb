require 'money'

module Coinstack
  # Formats and delivers data for the screeen
  class Printer
    attr_accessor :cli

    def initialize
      self.cli = HighLine.new
    end

    # Prints out a summary of the user's hodlings formatted nicely
    def pretty_print_user_list(list)
      total = 0
      data = []
      # Header row
      data.push('Asset', 'Total Value', 'Change % (Week)')
      list.user_pairs.each do |user_pair|
        data.push(user_pair.symbol)
        data.push(user_pair.valuation.format)
        data.push(user_pair.perchant_change_week.to_s)
        total += user_pair.valuation
      end

      data.push('', '', '')
      data.push('TOTAL:', total.format, '')
      data.push('', '', '')
      print_arrays(data, 3)
    end

    # Data should be an array of arays, cols is the number of columns it has
    # Prints the data to screen with equal spacing between them
    def print_arrays(data, cols)
      formatted_list = cli.list(data, :uneven_columns_across, cols)
      cli.say(formatted_list)
    end

    def clear_screen
      Gem.win_platform? ? (system 'cls') : (system 'clear')
    end

    # Returns the combined length of charaters in an array
    def array_char_length(input_array)
      length = 0
      input_array.each do |a|
        length += a.to_s.length
      end
      length
    end
  end
end
