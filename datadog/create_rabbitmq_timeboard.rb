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

dash_id = '83139'
data = from_dog.get_dashboard(dash_id)

title = "RabbitMQ Clusters"
description = "Overview of RabbitMQ performance"
graphs = data[1]['dash']['graphs']
template_variables = data[1]['dash']['template_variables']

puts "Creating System Overview Timeboard"
ret = to_dog.create_dashboard(title, description, graphs, template_variables)

if ret[0] == '200'
  puts "Timeboard created."
else
  puts "Failed to create timeboard. Returned: #{ret}"
end
