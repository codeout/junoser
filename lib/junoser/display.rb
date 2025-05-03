require 'junoser/display/set'
require 'junoser/display/structure'
require 'junoser/display/compare.rb'

module Junoser
  module Display
    class << self
      def display_set?(str)
        str =~ /\Aset|deactivate/
      end

      def structured?(str)
        !display_set?(str)
      end
    end
  end
end

# NOTE: Apply a patch
require 'junoser/display/enumerable'
