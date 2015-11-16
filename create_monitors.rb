require 'rubygems'
require 'dogapi'

api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

type = "metric alert"
query = "avg(last_15m):avg:system.cpu.idle{*} by {env,host,name} <= 10"
name = "High CPU Usage on {{host.name}}"
message = "{{#is_alert}} CPU Idle has been at or below 10% for 15 minutes {{/is_alert}}\n{{#is_recovery}} CPU has recovered{{/is_recovery}} \n\nHost Info:\n\n- Env: {{env.name}} \n- Hostname: {{host.name}}\n- Host Internal IP: {{host.ip}} \n- AWS Info: {{host.aws}} \n\n@sns-datadog-devops"

ret = dog.monitor(type, query, name: name, message: message)
puts ret
