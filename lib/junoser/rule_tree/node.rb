module Junoser
  module RuleTree
    class Node
      INDENT = '    '
      attr_reader :name, :children

      def initialize(name)
        @name = name
        @children = []
      end

      def <<(child)
        @children << child
      end

      def print(level = 0)
        puts INDENT * level + "- #{@name}"
        @children.each do |child|
          child.print level + 1
        end
      end
    end
  end
end
