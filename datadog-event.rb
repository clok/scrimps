#! /usr/bin/ruby

require 'ostruct'
require 'optparse'
require 'net/http'
require 'json'

def opts
  @opts ||= OpenStruct.new(
                           datadog_key: '<REQUIRED>',
                           level: 'info',
                           type: 'custom-event',
                           source_name: 'custom-source',
                           aggregation_key: 'custom-agg-key',
                           title: '[#{type}] Enter Custom Value',
                           aws_tags: true
                          )
end

def option_parser
  @option_parser ||= OptionParser.new do |o|
    o.banner = "USAGE: #{$0} [options]"

    o.on("--datadog-key [API_KEY]", "DataDog API Key. DEFAULT: #{opts.datadog_key}") do |h|
      opts.datadog_key = h
    end

    o.on("-d", "--[no-]debug", "Print debug") do |h|
      opts.debug = h
    end
    
    o.on("--tags [CSV_STRING]", "List of tags. Example: env:prod,app:runner") do |csv|
      tags = csv.split(',')
      opts.tags = tags
    end

    o.on("-l", "--level [EVENT_LEVEL]", "Must be: error, warning, info or success. DEFAULT: #{opts.level}") do |h|
      opts.level = h
    end

    o.on("-t", "--type [TYPE]", "Shorthand name for grouping similar style events. DEFAULT: #{opts.type}") do |h|
      opts.type = h
    end

    o.on("-s", "--source-name [NAME]", "Used for grouping events in the event stream. DEFAULT: #{opts.source_name}") do |h|
      opts.source_name = h
    end

    o.on("-a", "--aggregation-key [KEY]", "Used for grouping events in the event stream. It is not surfaced in the interface, but will cause all events within a window to be grouped in the view by default. Recommend using an application name or uniqe key. DEFAULT: #{opts.aggregation_key}") do |h|
      opts.source_name = h
    end

    o.on("--title [STRING]", "The event title. It will be appened with the 'type' that is entered. Example: With 'type' set to 'deploy-start' and 'title' set to 'Production user-map' the Event Title will be '[deploy-start] Production user-map'") do |t|
      opts.title_string = t
    end

    o.on("--[no-]aws-tags", "Grab all AWS tags from host for event. Useful for when a host is not configured to sync with DataDog by default. DEFAULT: #{opts.aws_tags}") do |h|
      opts.aws_tags = h
    end
    
    o.on("-h", "--help", "Show help documentation") do |h|
      STDERR.puts o
      exit
    end
  end
end

option_parser.parse!

opts.title = "[#{opts.type}] #{opts.title_string}"

# Add a base tag for the event
base_tags = ["type:#{opts.type}"]
all_tags = base_tags

# Merge with custom tags if they are set
if opts.tags
  all_tags = base_tags + opts.tags
end

# Pull AWS host tags and merge with tags list
if opts.aws_tags
  data = JSON.parse(Net::HTTP.get('169.254.169.254', '/latest/dynamic/instance-identity/document/'))
  instance_id = data['instanceId']
  region = data['region']

  raw_tags = `aws ec2 describe-tags --region=#{region} --filters Name=resource-id,Values=#{instance_id}`
  tag_data = JSON.parse(raw_tags)
  aws_tags = []

  tag_data['Tags'].each do |t|
    aws_tags.push([t['Key'], t['Value']].join(':'))
  end

  all_tags = all_tags + aws_tags
end

# Dedupe tags list
all_tags.uniq!

# Build data to post
data = {
        title: "#{opts.title}",
        aggregation_key: "#{opts.aggregation_key}",
        source_type_name: "#{opts.source_name}",
        priority: "normal",
        tags: all_tags,
        alert_type: "#{opts.level}"
       }

puts "#{data.to_json}" if opts.debug

cmd = "curl -X POST -H \"Content-type: application/json\" -d '#{data.to_json}' 'https://app.datadoghq.com/api/v1/events?api_key=#{opts.datadog_key}'"

# Do not execute curl call to pust data to DataDog if set to debug mode
if opts.debug
  puts "Would execute: #{cmd}"
  exit
end

ret = `#{cmd}`

if ret =~ /"status":"ok"/
  puts "Event sent successfully."
else
  STDERR.puts "Error sending event: #{ret}"
end
