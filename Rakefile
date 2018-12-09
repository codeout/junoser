require 'bundler/gem_tasks'
require 'junoser/development'
require 'nokogiri'
require 'pathname'
require 'rake/testtask'

xsd_path = File.join(__dir__, 'tmp/junos-system-17.2.xsd')
rule_path = File.join(__dir__, 'tmp/rule.rb')
ruby_parser_path = File.join(__dir__, 'lib/junoser/parser.rb')

def open_files(input, output, &block)
  i = open(input)
  o = open(output, 'w')

  yield i, o

  i.close
  o.close
end


namespace :build do
  desc 'Build an intermediate config hierarchy'
  task(:config) do
    open_files(xsd_path, rule_path) do |input, output|
      Nokogiri::XML(input).root.remove_unused.xpath('/xsd:schema/*').each do |e|
        output.puts e.to_config
      end
    end
  end

  desc 'Build ruby parser'
  task(:rule) do
    open_files(rule_path, ruby_parser_path) do |input, output|
      output.puts Junoser::Ruler.new(input).to_rule
    end
  end
end


Rake::TestTask.new do |t|
  t.libs << 'test'

  t.verbose = true
  t.warning = false
end

desc 'Run tests'
task default: :test
