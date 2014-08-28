#!/bin/ruby
ENV['AB_BRANCH'] = 'devel'
gem "minitest"
require 'minitest/autorun'
require "../../bundler/bundlets/alfred.bundler.rb"


class TestTruthiness < MiniTest::Unit::TestCase

  def setup
    @b = Alfred::Bundler.new
  end

# Just so I can get the general idea
  def test_assert_true
    assert true
  end

  def test_assert_false
    refute false
  end

  def test_bundler_class_exists
    assert !!Module.const_get("Alfred::Bundler")
  end

  def test_bundler_internal_class_exists
    assert !!Module.const_get("Alfred::Internal")
  end

  def test_bundler_log_class_exists
    assert !!Module.const_get("Alfred::Log")
  end

  def test_bundler_icon_class_exists
    assert !!Module.const_get("Alfred::Icon")
  end

  def test_plist
    assert @b.is_there_a_plist?
  end

  def test_system_icon
    assert File.exists? @b.icon('system', 'Accounts')
  end

  def test_icon
    assert File.exists? @b.icon('elusive', 'fire', '000000')
  end

  # needs work
  def test_bad_icon
    skip "refute File.exists? @b.icon('asd', 'fire', '000000')"
  end

  def test_icon_hash
    assert File.exists? @b.icon({:font => 'elusive', :name => 'fire', :color => '000000'})
  end

  def test_icon_array
    assert File.exists? @b.icon(['elusive', 'fire', '000000'])
  end

  def test_utility
    # this fails... why?
    assert File.exists? @b.utility('cocoaDialog')
  end

  def test_load
    #this fails, why?
    file = @b.load('utility', 'cocoaDialog')
    assert File.exists? "#{file}"
  end

  def test_wrapper
    @b.wrapper('cocoadialog')
    assert !!Module.const_get("Alfred::CocoaDialog")
  end

  def test_gem
    # @b.gems(['oauth'])
    # require "plist"
    # assert defined?('plist')
  end


end

exit





# require "minitest/autorun"




# class TestAssets < Minitest::Test


#   def test_icon_system_test
#     icon = @b.icon('system', 'Accounts')
#     assert
#   end
# end



# ### Helper functions to randomize tests
# def rhex()
#     return "%06x" % (rand * 0xffffff)
# end

# ### End helper functions

# #### Icon tests

# def icon_system_test
#     puts
# end

# def icon_system_fail_test
#     puts $bundler.icon('system', 'Accouasdfnts')
# end

# def icon_download_test
#     color = rhex()
#     puts $icon.icon('elusive', 'fire', color )
# end
# ####




# # Queue the tests
# tests = [
# # 'icon_system_test',
# # 'icon_system_fail_test',
# 'icon_download_test'
# ]









# $bundler = Alfred::Bundler.new

# $icon = Alfred::Icon.new


# # Run the tests
# tests.each do |test|
#     send("#{test}")
# end