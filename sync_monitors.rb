# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

# Account to sync from (Synctree)
from_api_key = ''
from_app_key = ''

# Account to sync to
to_api_key = ''
to_app_key = ''

from_dog = Dogapi::Client.new(from_api_key, from_app_key)
to_dog = Dogapi::Client.new(to_api_key, to_app_key)

from_data = from_dog.get_all_monitors()
to_data = to_dog.get_all_monitors()

from_monitors = {}
to_monitors = {}

from_data[1].each do |m|
  from_monitors[m['name']] = m
end

to_data[1].each do |m|
  to_monitors[m['name']] = m
end

from_monitors.keys.each do |m|
  unless to_monitors[m] # || m =~ /Rabbit/
    puts "Creating: #{m}"
    ret = to_dog.monitor(from_monitors[m]['type'], from_monitors[m]['query'], name: m, message: from_monitors[m]['message'])
    if ret[0] == '200'
      puts "Monitor created."
    else
      puts "Failed to create monitor. Returned: #{ret}"
    end
  else
    puts "Skipping: #{m}"
  end
end

