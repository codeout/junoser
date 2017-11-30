require 'junoser/input'
require 'junoser/display/config_store'
require 'junoser/parser'
require 'junoser/transformer'

module Junoser
  module Display
    class Delete
      def initialize(io_or_string)
        @input = io_or_string
      end
      def apply
        sd = Junoser::Input.new(@input).read.split("\n")
        d = sd.grep(/^delete /).map {|l| l.sub(/^delete /, 'set ')}
        s = sd.grep(/^set /)
        set_struct = Junoser::Display::Structure.new(s.join("\n")).transform
        set_h = struct_to_hash(set_struct)
        d.each do |delete_line|
          delete_line_struct = Junoser::Display::Structure.new(delete_line).transform
          delete_line_hash = struct_to_hash(delete_line_struct)
          set_h = apply_delete(set_h,delete_line_hash)
        end
        set_h
#        set_struct = hash_to_struct(set_h)
#        Junoser::Display::Set.new(set_struct).transform
      end

      private

      def struct_to_hash(struct)
        struct.gsub!(/\n/, '')
        hash = struct_to_first_hash(struct)
        hash_value_to_hash(hash)
      end

      def hash_value_to_hash(hash)
        hash.each do |key,value|
          if value != {}
            hash.store(key,struct_to_first_hash(value))
            hash_value_to_hash(hash[key])
          end
        end
      end

      def struct_to_first_hash(struct)
        hash = {}
        ar = ["",""]
        num = 0
        flag = 0
        struct << " "
        struct.chars.each do |c|
          if num != 0
            ar[1] << c
          end
          if c == "{"
            num = num + 1
            flag = 1
            next
          end
          if c == "}"
            num = num - 1
            next
          end
          if num == 0
            if c == ";"
              hash.store(ar[0].strip,{})
              ar = ["",""]
              next
            end
            if flag == 1
              hash.store(ar[0].strip,ar[1].chop.strip)
              ar = ["",""]
              flag = 0
            end
            ar[0] << c
          end
        end
        hash
      end

      def apply_delete(set_hash,delete_line_hash)
        key,hash = ret_first_key_and_value(delete_line_hash)
        if hash == {}
          set_hash.delete(key)
          set_hash
        else
          apply_delete(set_hash[key],hash)
        end
        set_hash
      end

#      def hash_to_struct(hash)
#
#      end

      def ret_first_key_and_value(hash)
        hash.each do |key,hash|
          return key,hash
        end
      end
    end
  end
end
