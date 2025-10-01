# frozen_string_literal: true

require 'helper'

class TestInvalidStatements < Test::Unit::TestCase
  test 'syntax check to fail' do
    config = <<~CONFIG
      set protocols ospf area 0.0.0.0 export opsf-export

      set class-of-service schedulers foo drop-profile-map protocol any
      set class-of-service schedulers foo drop-profile-map drop-profile bar
    CONFIG

    config.split("\n").reject(&:empty?).each do |l|
      assert_false Junoser::Cli.commit_check(l), %("#{l}" should be invalid)
    end
  end
end
