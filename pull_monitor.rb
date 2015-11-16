# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

dash_id = '291893'
puts dog.get_monitors(dash_id)
