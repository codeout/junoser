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
      %[#{label}\n#{children.join("\n")}]
    end

    rule(oneline: simple(:str)) do
      str.gsub "\n", ' '
    end
  end
end
