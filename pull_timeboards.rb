# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

dash_id = '80973'
data = dog.get_dashboard(dash_id)

puts "#{data}"
