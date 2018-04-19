require 'junoser/display/set'
require 'junoser/display/structure'
require 'junoser/display/delete'
require 'junoser/display/compare'

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
