module Junoser
  class JsRuler

    def initialize(input)
      @rule = input
    end

    def to_rule
      rule
    end

    def rule
      str = @rule.read
    end
  end
end
