# frozen_string_literal: true

require 'English'
require 'parslet'
require 'junoser/input'

module Junoser
  module Display
    class Set
      def initialize(io_or_string)
        @input = io_or_string
      end

      def transform
        result = +''

        process do |current_stack, str|
          result << transform_line(current_stack, str) << "\n"
        end

        result
      end

      def commit_check
        begin
          lines = transform
        rescue StandardError
          warn $ERROR_INFO
          return false
        end

        parser = Junoser::Parser.new
        parser.parse_lines(lines)
      end

      private

      def process
        stack = []

        Junoser::Input.new(@input).read.split("\n").each do |line|
          case line
          when /(?!.*})(.*){/
            stack.push ::Regexp.last_match(1).strip
          when /}\s*$/
            stack.pop
          when /((?!\[).*)\[(.*)\];/
            ::Regexp.last_match(2).split.each do |i|
              yield stack, "#{::Regexp.last_match(1).strip} #{i}"
            end
          when /(.*);/
            yield stack, ::Regexp.last_match(1)
          else
            raise "ERROR: unknown statement:  #{line}"
          end
        end
      end

      def transform_line(current_stack, str)
        statements = []
        current_statement = +''

        current_stack.each do |stack|
          stack.gsub! 'replace: ', ''

          statements << "deactivate #{current_statement}#{stack}" if stack.gsub!('inactive: ', '')
          current_statement << "#{stack} "
        end

        str.gsub! 'replace: ', ''

        statements << "deactivate #{current_statement}#{str}" if str.gsub!('inactive: ', '')

        statements.unshift "set #{current_statement}#{str}"
        statements.join("\n")
      end
    end
  end
end
