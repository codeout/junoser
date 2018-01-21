require 'junoser/input'
require 'junoser/display/config_store'
require 'junoser/parser'
require 'junoser/transformer'

module Junoser
  module Display
    class Compare
      def initialize(io_or_string)
        @input = io_or_string
      end
      def diff
        master,branch = Junoser::Input.new(@input).read2
        master_struct = Junoser::Display::Structure.new(master).transform
        branch_struct = Junoser::Display::Structure.new(branch).transform
        generate_diff_set_and_delete(master_struct,branch_struct)
      end

      private

      def generate_diff_set_and_delete(master,branch)
        master_hash = struct_to_hash(master)
        branch_hash = struct_to_hash(branch)
        set_hash = hash_cmp(master_hash,branch_hash,"set")
        delete_hash = hash_cmp(master_hash,branch_hash,"delete")
        set_struct = hash_to_struct(set_hash)
        delete_struct = hash_to_struct(delete_hash)
        set_ = Junoser::Display::Set.new(set_struct).transform
        delete_ = Junoser::Display::Set.new(delete_struct).transform
        delete_.gsub!(/^set /, 'delete ')
        delete_ << "\n" << set_
      end


      def hash_cmp(master,branch,delete_or_set,depth = 0)
        if delete_or_set == "set" and depth == 0
          tmp = master
          master = branch
          branch = tmp
        end
        answer = {}
        master.each do |key,value|
          if branch.key?(key)
            if not including(value,branch[key])
              answer.store(key,hash_cmp(value,branch[key],delete_or_set,depth + 1))
            end
          else
            if delete_or_set == "delete"
              answer.store(key,{})
            elsif delete_or_set == "set"
              answer.store(key,value)
            end
          end
        end
        answer
      end

      def including(hash,hash2)
        # hash <= hash2
        if hash.keys - hash2.keys == []
          if hash == {}
            return true
          else
            hash.each do |key,value|
              if not including(value,hash2[key])
                return false
              end
            end
          end
        else
          return false
        end
        true
      end

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
        key,value = "",""
        state = 0
        struct.strip!
        struct.chars.each do |c|
          case state
            when 0 then # initial state
              case c
                when "{" then
                  state += 1 # 1
                when ";" then
                  hash.store(key.strip,value.strip)
                  key,value = "",""
                else
                  key << c
              end
            when 1 then
              case c
                when "{" then
                  value << c
                  state += 1 # 2
                when "}" then
                  hash.store(key.strip,value.strip)
                  key,value = "",""
                  state -= 1 # 0
                else
                  value << c
              end
            else
              case c
                when "{" then
                  value << c
                  state += 1
                when "}" then
                  value << c
                  state -= 1
                else
                  value << c
              end
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

      def hash_to_struct(hash)
        struct = ""
        hash_to_struct_iter(hash){|str| struct << str}
        struct
      end

      def hash_to_struct_iter(hash,&block)
        hash.each_with_index do |(key,value),i|
          yield key
          if value != {}
            yield "{\n"
            hash_to_struct_iter(value,&block)
          else
            yield ";\n"
          end
          if i == hash.length - 1
            yield "}\n"
          end
        end
      end

      def ret_first_key_and_value(hash)
        hash.each do |key,hash|
          return key,hash
        end
      end
    end
  end
end
