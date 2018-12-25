require 'junoser/display/config_store'

module Junoser
  module Display
    module Enumerable
      attr_accessor :in_from, :in_then, :in_group

      def to_enum
        if @hash.size > 1
          "[#{@hash.keys.join(' ')}]"
        else
          @hash.keys.first
        end
      end

      private

      def hash_item_to_s(key, value, str)
        value.in_from = true if key == 'from'
        value.in_then = true if key == 'then'
        value.in_group = true if key =~ /^group /

        if in_from && ['next-header', 'port', 'protocol'].include?(key) ||
            in_then && key == 'origin' ||
            in_group && key == 'type'
          str << Junoser::Display::ConfigStore::OFFSET * @depth << "#{key} #{value.to_enum};\n"
        else
          super
        end
      end
    end
  end
end

Junoser::Display::ConfigStore.prepend(Junoser::Display::Enumerable)
