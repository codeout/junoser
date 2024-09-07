module Junoser
  module RuleTree
    class Parser
      def initialize(content)
        @content = content
        @nodes = {}
        @root = nil
      end

      def print
        parse
        @nodes['configuration'].print 0
      end

      def parse
        rules = content.scan(/^rule\(:([a-z\d_]+)\) do\n(.*?)^end/m)
        root_index = rules.index { |r| r[0] == 'configuration' }
        primitives = rules.map(&:first)
                          .then { |r| r[0, root_index] } + %w[any]

        validate_uniq rules[root_index..].map(&:first)

        @nodes = Hash[rules[root_index..].map { |name, _| [name, Node.new(name)] }]
        used = Set.new

        rules[root_index..].map do |name, refs|
          children = refs.split.map { |i| i.strip.gsub(/,$/, '') }
                         .reject { |i| primitives.include?(i) }
                         .uniq
          used += children
          children.each do |child|
            raise %(Unknown rule: #{child}) unless @nodes[child]
            @nodes[name] << @nodes[child]
          end
        end

        validate_used @nodes.keys, used.to_a
      end

      private

      def content
        @_content ||= @content
                        .gsub(%r| */\*.*\*/|, '')
                        .gsub(/\.as\(:oneline\)/, '')
                        .gsub(/^(?!rule.*).*["#()].*\n/, '')
                        .gsub(/ *arg,?\n/, '')
      end

      def validate_uniq(rules)
        duplicates = rules.group_by(&:itself).select { |_, v| v.count > 1 }.keys
        return if duplicates.empty?

        raise %(Duplicated rules:\n  - #{duplicates.join("\n  - ")}) unless duplicates.empty?
      end

      def validate_used(all, used)
        unused = all - used - %w[configuration]
        return if unused.empty?

        $stderr.puts 'Warning: Unused rules:'
        unused.each { |r| $stderr.puts "  - #{r}" }
      end
    end
  end
end
