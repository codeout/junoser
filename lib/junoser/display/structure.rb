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

        Junoser::Input.new(@input).read.split("\n").each do |line|
          transformed = transform.apply(parser.parse(line))
          raise "ERROR: parse failed" unless transformed.is_a?(String)
          @config << transformed
        end

        @config.to_s
      end
    end
  end
end
