require 'optparse'
require 'ostruct'
require 'json'
require 'date'

def opts
  @opts ||= OpenStruct.new(
    verbose: false,
    region: 'us-east-1',
    aws_profile: 'conversionlogic',
    start_time: (Date.today - 2).strftime('%Y-%m-%dT00:00:00'),
    end_time: (Date.today - 1).strftime('%Y-%m-%dT00:00:00')
  )
end

def option_parser
  @option_parser ||= OptionParser.new do |o|
    o.banner = "USAGE: #{$0} [options]"

    o.on("-a", "--aws-profile [AWS_PROFILE]", "AWS profile for boto. Default: #{opts.aws_profile}") do |h|
      opts.aws_profile = h
    end

    o.on("-r", "--region [AWS_REGION]", "AWS Region. Default: #{opts.region}") do |r|
      opts.region = r
    end

    o.on("-s", "--start-time [TIMESTAMP]", "Pattern: YYYY-MM-DDT00:00:00 Default: #{opts.start_time}") do |t|
      opts.start_time = t
    end

    o.on("-e", "--end-time [TIMESTAMP]", "Pattern: YYYY-MM-DDT00:00:00 Default: #{opts.end_time}") do |t|
      opts.end_time = t
    end

    o.on("-v", "--verbose", "Print debug") do |h|
      opts.verbose = true
    end

    o.on("-h", "--help", "Show help documentation") do |h|
      STDERR.puts o
      exit
    end
  end
end

option_parser.parse!

STDERR.puts "[#{Time.now}] Start"

buckets_json = `AWS_PROFILE=#{opts.aws_profile} aws s3api list-buckets --region #{opts.region}`

buckets = JSON.parse(buckets_json)["Buckets"].map {|b| b["Name"]}

puts "Bucket,Objects,Size (Bytes),Size (Gigabytes),Bytes per Oject,MB per Object,App,Role"
buckets.each do |bucket|
  STDERR.puts "[#{Time.now}] Processing Bucket: #{bucket}"

  tags = {}
  begin
    tags_json = `AWS_PROFILE=#{opts.aws_profile} aws s3api get-bucket-tagging --region #{opts.region} --bucket #{bucket}`
    JSON.parse(tags_json)["TagSet"].each do |t|
      tags[t['Key']] = t['Value']
    end
  rescue Exception => e
    STDERR.puts "[#{Time.now}] Bucket has NO tags: #{bucket}"
  end

  size_output_json = `AWS_PROFILE=#{opts.aws_profile} aws cloudwatch get-metric-statistics --namespace AWS/S3 --start-time #{opts.start_time} --end-time #{opts.end_time} --period 86400 --statistics Average --region #{opts.region} --metric-name BucketSizeBytes --dimensions Name=BucketName,Value=#{bucket} Name=StorageType,Value=StandardStorage`

  objects_output_json = `AWS_PROFILE=#{opts.aws_profile} aws cloudwatch get-metric-statistics --namespace AWS/S3 --start-time #{opts.start_time} --end-time #{opts.end_time} --period 86400 --statistics Average --region #{opts.region} --metric-name NumberOfObjects --dimensions Name=BucketName,Value=#{bucket} Name=StorageType,Value=AllStorageTypes`

  size_output    = JSON.parse(size_output_json)
  objects_output = JSON.parse(objects_output_json)
  begin
    objects = objects_output['Datapoints'][0]['Average']
    bytes = size_output['Datapoints'][0]['Average']
    gigabytes = (bytes / 1000 / 1000 / 1000).round(2)
    bytes_per_object = (bytes / objects).round(2)
    mb_per_object = (bytes / objects / 1000 / 1000).round(2)
    puts "#{bucket},#{objects},#{bytes},#{gigabytes},#{bytes_per_object},#{mb_per_object},#{tags.has_key?('app') ? tags['app'] : ''},#{tags.has_key?('role') ? tags['role'] : ''}"
  rescue Exception => e
    STDERR.puts "Bucket #{bucket} has an error. Most likely empty"
  end
end

STDERR.puts "[#{Time.now}] Done"
