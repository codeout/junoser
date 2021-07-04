require 'bundler/gem_tasks'
require 'junoser/development'
require 'nokogiri'
require 'pathname'
require 'rake/testtask'

xsd_path = File.join(__dir__, 'tmp/junos-system-19.3.xsd')
rule_path = File.join(__dir__, 'tmp/rule.rb')
ruby_parser_path = File.join(__dir__, 'lib/junoser/parser.rb')
js_parser_path = File.join(__dir__, 'tmp/junos.js')

def open_files(input, output, &block)
  i = open(input)
  o = open(output, 'w')

  yield i, o

  i.close
  o.close
end

def move_wildcards(element)
  ['ipaddr', 'ipv6addr', 'ipprefix'].each do |pattern|
    element.xpath(%[.//xsd:element[@type="#{pattern}"]/xsd:annotation/xsd:appinfo/flag[text()="nokeyword"]/../../..]).each do |wildcard|
      parent = wildcard.parent
      removed = wildcard.remove
      parent << removed
    end
  end
end

namespace :build do
  desc 'Build an intermediate config hierarchy'
  task :config do
    open_files(xsd_path, rule_path) do |input, output|
      Nokogiri::XML(input).root.remove_unused.xpath('/xsd:schema/*').each do |e|
        move_wildcards e # Move wildcard elements to the end of siblings as they capture keywords unexpectedly
        output.puts e.to_config
      end
    end
  end

  desc 'Build ruby parser'
  task :rule do
    open_files(rule_path, ruby_parser_path) do |input, output|
      output.puts Junoser::Ruler.new(input).to_rule
    end
  end

  desc 'Build javascript parser'
  task :jsrule do
    open_files(rule_path, js_parser_path) do |input, output|
      output.puts Junoser::JsRuler.new(input).to_rule
    end
  end
end

task 'find-srx-methods' do
  vsrx = File.read('vsrx.rb')
  vmx = File.read('lib/junoser/parser.rb')

  vsrx.scan(/^ +([0-9a-z_]+) *$/).flatten.uniq.sort.each do |method|
    next if ['arg', 'end', 'ipaddr', 'time'].include?(method)

    puts method unless vsrx =~ /rule\(:#{method}\)/m || vmx =~ /rule\(:#{method}\)/m
  end
end

Rake::TestTask.new do |t|
  t.libs << 'test'

  t.verbose = true
  t.warning = false
end

desc 'Run tests'
task default: :test
