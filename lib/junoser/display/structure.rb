require 'junoser/display/config_store'
require 'junoser/parser'
require 'junoser/transformer'

module Junoser
  module Display
    class Structure
      include Base

      def initialize(io_or_string)
        super
        @config = Junoser::Display::ConfigStore.new
      end

      def transform
        parser = Junoser::Parser.new
        transform = Junoser::Transformer.new

        read_io_or_string.split("\n").each do |line|
          transformed = transform.apply(parser.parse(line))
          raise "ERROR: parse failed" unless transformed.is_a?(String)
          @config << transformed
        end

        @output.puts @config.to_s
      end
    end
  end
end
