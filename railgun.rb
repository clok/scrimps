#! /usr/bin/ruby
require 'dogapi'
require 'json'

dog = Dogapi::Client.new('', '')

metrics = 0
ret = `curl -s localhost:24088`

data = JSON.parse(ret)

data.each do |k,v|
  next if k == 'version' || k == 'time'
  key = "railgun.#{k}"
  dog.emit_point(key, v)
  #puts "#{key} -> #{v}"
  metrics += 1
end

puts "[#{Time.now}] Emitted #{metrics} metrics"
