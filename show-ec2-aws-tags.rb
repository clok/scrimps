#! /usr/bin/ruby

require 'net/http'
require 'json'

data = JSON.parse(Net::HTTP.get('169.254.169.254', '/latest/dynamic/instance-identity/document/'))

instance_id = data['instanceId']
region = data['region']

raw_tags = `aws ec2 describe-tags --region=#{region} --filters Name=resource-id,Values=#{instance_id}`
tag_data = JSON.parse(raw_tags)

tags = []

tag_data['Tags'].each do |t|
  tags.push([t['Key'], t['Value']].join(':'))
end

puts tags
