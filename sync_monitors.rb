# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

sc_api_key = ''
sc_app_key = ''
tn_api_key = ''
tn_app_key = ''

sc_dog = Dogapi::Client.new(sc_api_key, sc_app_key)
tn_dog = Dogapi::Client.new(tn_api_key, tn_app_key)

sc_data = sc_dog.get_all_monitors()
tn_data = tn_dog.get_all_monitors()

sc_monitors = {}
tn_monitors = {}

sc_data[1].each do |m|
  sc_monitors[m['name']] = m
end

tn_data[1].each do |m|
  tn_monitors[m['name']] = m
end

sc_monitors.keys.each do |m|
  unless tn_monitors[m] ||  m =~ /Rabbit/
    puts "Creating: #{m}"
    ret = tn_dog.monitor(sc_monitors[m]['type'], sc_monitors[m]['query'], name: m, message: sc_monitors[m]['message'])
    if ret[0] == 200
      puts "Monitor created."
    else
      puts "Failed to create monitor."
    end
  else
    puts "Skipping: #{m}"
  end
end

