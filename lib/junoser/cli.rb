require 'parslet'
require 'junoser/display'
require 'junoser/parser'


module Junoser
  module Cli
    class << self
      def commit_check(io_or_string)
        config = if io_or_string.respond_to?(:read)
                   io_or_string.read
                 else
                   io_or_string.to_s
                 end

        if Junoser::Display.display_set?(config)
          commit_check_display_set config
        else
          commit_check_structured config
        end
      end

      def display_set(io_or_string)
        Junoser::Display::Set.new(io_or_string).transform
      end

      def struct(io_or_string)
        Junoser::Display::Structure.new(io_or_string).transform
      end


      private

      def commit_check_structured(config)
        Junoser::Display::Set.new(config).commit_check
      end

      def commit_check_display_set(config)
        parser = Junoser::Parser.new
        failed = false

        config.split("\n").each do |line|
          begin
            parser.parse line
          rescue Parslet::ParseFailed
            $stderr.puts "Invalid syntax:  #{line}"
            failed = true
          end
        end

        abort if failed
      end
    end
  end
end
