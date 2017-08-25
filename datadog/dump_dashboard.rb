require 'rubygems'
require 'dogapi'
require 'json'
require 'ostruct'
require 'optparse'
require 'pp'

api_key = ''
app_key = ''

dog = Dogapi::Client.new(api_key, app_key)

dash_id = ARGV[0]
data = dog.get_dashboard(dash_id)

#title = "System Overview"
#description = "Overview of key system metrics"
#graphs = data[1]['dash']['graphs']
#template_variables = data[1]['dash']['template_variables']

#ret = to_dog.create_dashboard(title, description, graphs, template_variables)

# if ret[0] == '200'
#   puts "Timeboard created."
# else
#   puts "Failed to create timeboard. Returned: #{ret}"
# end

pp data[1]['dash']['graphs']

puts

pp data[1]['dash']['template_variables']
