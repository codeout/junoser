require 'parslet'
require 'junoser/display'
require 'junoser/parser'


module Junoser
  module Cli
    class << self
      def commit_check
        config = $<.read

        if Junoser::Display.display_set?(config)
          commit_check_display_set config
        else
          commit_check_structured config
        end
      end

      def display_set
        Junoser::Display::Set.new($<).transform
      end

      def struct
        Junoser::Display::Structure.new($<).transform
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
