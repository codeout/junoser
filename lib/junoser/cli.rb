require 'parslet'
require 'junoser/display'
require 'junoser/input'
require 'junoser/parser'


module Junoser
  module Cli
    class << self
      def commit_check(io_or_string)
        config = Junoser::Input.new(io_or_string).read

        if Junoser::Display.display_set?(config)
          commit_check_display_set config
        else
          commit_check_structured config
        end
      end

      def display_set(io_or_string)
        config = Junoser::Input.new(io_or_string).read

        if Junoser::Display.display_set?(config)
          config
        else
          Junoser::Display::Set.new(config).transform
        end
      end

      def struct(io_or_string)
        config = Junoser::Input.new(io_or_string).read

        if Junoser::Display.display_set?(config)
          Junoser::Display::Structure.new(config).transform
        else
          config
        end
      end
      def compare(io_or_string)
        Junoser::Display::Compare.new(io_or_string).diff
      end

      private

      def commit_check_structured(config)
        Junoser::Display::Set.new(config).commit_check
      end

      def commit_check_display_set(config)
        parser = Junoser::Parser.new
        parser.parse_lines(config)
      end
    end
  end
end
