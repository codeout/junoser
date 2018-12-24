require 'junoser'
require 'parslet'

module Junoser
  class DeleteTransformer < Parslet::Transform
    rule(config: simple(:config)) do
      "(#{config.to_s} .*"
    end

    rule(config: sequence(:configs)) do
      configs.join("\n")
    end

    rule(arg: simple(:arg)) do
      arg
    end

    rule(label: simple(:label)) do
      ")#{Regexp.escape(label.to_s)}"
    end

    rule(label: simple(:label), child: simple(:child)) do
      "#{Regexp.escape(label.to_s)} #{child}"
    end

    rule(label: simple(:label), child: sequence(:children)) do
      %[#{Regexp.escape(label.to_s)} #{children.join(' ')}]
    end

    rule(statement: simple(:statement), argument: simple(:argument)) do
      "#{statement} #{argument}"
    end

    rule(statement: simple(:statement), argument: sequence(:arguments)) do
      %[#{statement} #{arguments.join(' ')}]
    end

    rule(oneline: simple(:str)) do
      str
    end

    rule(oneline: sequence(:strs)) do
      strs.join(' ')
    end

    rule(enum: simple(:str)) do
      str
    end

    rule(enum: sequence(:strs)) do
      strs.join(' ')
    end
  end

  class Squash
    def initialize(io_or_string)
      @input = io_or_string
      @lines = []
      @parser = Junoser::Parser.new
      @transformer = DeleteTransformer.new
    end

    def transform
      config = Junoser::Input.new(@input).read.split("\n")
      config.each do |l|
        l.strip!
        case l
          when /^set /
            @lines << l
          when /^delete /
            to_delete = @parser.parse(l.gsub(/^delete /, 'set '))
            delete_lines @transformer.apply(to_delete)
        end
      end

      @lines.uniq!
      remove_subcommand(@lines).map(&:strip).join("\n")
    end

    private

    def remove_subcommand(lines)
      lines.each_with_index do |l,i|
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
  end
end
