require 'parslet'

module Junoser
  class Transformer < Parslet::Transform
    rule(config: simple(:config)) do
      config.to_s
    end

    rule(config: sequence(:configs)) do
      configs.join("\n")
    end

    rule(arg: simple(:arg)) do
      "arg(#{arg})"
    end

    rule(label: simple(:label)) do
      label.to_s
    end

    rule(label: simple(:label), child: simple(:child)) do
      "#{label}\n#{child}"
    end

    rule(label: simple(:label), child: sequence(:children)) do
      Junoser::Transformer.remove_slash_asterisk children
      %[#{label}\n#{children.join("\n")}]
    end

    rule(statement: simple(:statement), argument: simple(:argument)) do
      "#{statement} #{argument}"
    end

    rule(statement: simple(:statement), argument: sequence(:arguments)) do
      Junoser::Transformer.remove_slash_asterisk arguments
      %[#{statement}\n#{arguments.join("\n")}]
    end

    rule(oneline: simple(:str)) do
      str.to_s.gsub("\n", ' ')
    end

    rule(oneline: sequence(:strs)) do
      strs.join(' ')
    end


    def self.remove_slash_asterisk(array)
      open = array.index("arg(/*)\n")
      close = array.index("arg(*/)")

      if open && close
        (open..close).reverse_each do |i|
          array.delete_at i
        end
      end
    end
  end
end
