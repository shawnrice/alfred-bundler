#!/bin/ruby

require "../../bundler/bundlets/alfred.bundler.rb"

### Helper functions to randomize tests
def rhex()
    return "%06x" % (rand * 0xffffff)
end

### End helper functions

#### Icon tests

def icon_system_test
    puts $bundler.icon('system', 'Accounts')
end

def icon_system_fail_test
    puts $bundler.icon('system', 'Accouasdfnts')
end

def icon_download_test
    color = rhex()
    puts $icon.icon('elusive', 'fire', color )
end
####




# Queue the tests
tests = [
# 'icon_system_test',
# 'icon_system_fail_test',
'icon_download_test'
]









$bundler = Alfred::Bundler.new

$icon = Alfred::Icon.new


# Run the tests
tests.each do |test|
    send("#{test}")
end