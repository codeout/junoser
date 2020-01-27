require 'junoser'
require 'parslet'

module Junoser
  class Squash
    def initialize(io_or_string)
      @input = io_or_string
      @lines = []
      @parser = Junoser::Parser.new
      @transformer = Junoser::Transformer.new
    end

    def transform
      config = Junoser::Input.new(@input).read.split("\n")
      config.each do |l|
        l.strip!
        case l
        when /^(set|deactivate) /
          @lines << l
        when /^delete /
          delete_lines delete_pattern(l.gsub(/^delete /, 'set '))
        when /^activate /
          delete_lines l.gsub(/^activate /, 'deactivate ')
        when /^insert (.*) before (.*)/
          insert_before insert_pattern("set #{$1}"), $2
        when /^insert (.*) after (.*)/
          insert_after insert_pattern("set #{$1}"), $2
        end
      end

      @lines.uniq!
      remove_subcommand(@lines).map(&:strip).join("\n")
    end

    private

    def remove_subcommand(lines)
      lines.each_with_index do |l, i|
        lines[i..-1].each do |l2|
          if l.include?(l2) and l != l2
            lines.delete(l2)
          end
        end
      end
    end

    def delete_lines(pattern)
      @lines.each do |l|
        l.sub!(/#{pattern}/) { $1 }
      end
    end

    def split_last_token(line)
      tokens = join_arg(@transformer.apply(@parser.parse(line))).split("\n")
      tokens.map! { |t|
        t.gsub!(/arg\((.*)\)/) { "#$1" } # Strip arg
        Regexp.escape(t.strip)
      }

      [tokens[0..-2].join(' '), tokens.last]
    end

    # Ported from lib/junoser/display/config_store.rb
    def join_arg(str)
      str.gsub!(/\narg\((.*)\)$/) { " #$1" }
      str.gsub!(/arg\((.*)\)/) { "#$1" }
      str
    end

    def delete_pattern(line)
      line, last_token = split_last_token(line)
      "(#{line}\s+)#{last_token}.*"
    end

    def insert_pattern(line)
      line, last_token = split_last_token(line)
      "(#{line})\s+#{last_token}"
    end

    def insert_before(pattern_to_insert, key_token)
      key_pattern = pattern_to_insert.sub(/\).*/) { ") #{key_token}" }

      lines_to_insert = @lines.select { |l| l =~ /#{pattern_to_insert}/ }
      @lines.reject! { |l| l =~ /#{pattern_to_insert}/ }

      key_index = @lines.index { |l| l =~ /#{key_pattern}/ }
      @lines.insert(key_index, lines_to_insert).flatten!
    end

    def insert_after(pattern_to_insert, key_token)
      @lines.reverse!
      insert_before pattern_to_insert, key_token
      @lines.reverse!
    end
  end
end
