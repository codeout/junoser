# frozen_string_literal: true

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

        config = Junoser::Input.new(@input).read.split("\n").map(&:strip)
        deactivated_lines = []

        config.each do |line|
          # .xsd doesn't include "apply-groups"
          apply_groups = trim_apply_groups(line)
          if line == 'set'
            @config << apply_groups
            next
          end

          if line =~ /^deactivate *(.*)/
            deactivated_lines << "#{::Regexp.last_match(1)} #{apply_groups}".strip
            next
          end

          transformed = transform.apply(parser.parse(line))
          raise "ERROR: Failed to parse \"#{line}\"" unless transformed.is_a?(String)

          transformed << "\n#{apply_groups}" if apply_groups

          @config << transformed
        end

        deactivated_lines.each { |l| @config.deactivate l }

        @config.to_s
      end

      private

      def trim_apply_groups(line)
        line.gsub!(/\s+(apply-groups(-except)?\s+.*)/, '')
        ::Regexp.last_match(1)
      end
    end
  end
end
