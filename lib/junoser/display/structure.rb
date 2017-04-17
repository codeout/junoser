require 'junoser/input'
require 'junoser/display/config_store'
require 'junoser/parser'
require 'junoser/transformer'

module Junoser
  module Display
    class Structure
      def initialize(io_or_string)
        @input = io_or_string
        @config = Junoser::Display::ConfigStore.new
      end

      def transform
        parser = Junoser::Parser.new
        transform = Junoser::Transformer.new

        config = Junoser::Input.new(@input).read.split("\n")
        deactivated_lines = config.grep(/^deactivate /).map {|l| l.sub(/^deactivate /, '') }

        config.each do |line|
          next if line =~ /^deactivate /

          transformed = transform.apply(parser.parse(line))
          raise "ERROR: parse failed" unless transformed.is_a?(String)
          @config << transformed
        end

        deactivated_lines.each {|l| @config.deactivate l }

        @config.to_s
      end
    end
  end
end
