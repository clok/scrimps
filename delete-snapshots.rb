require 'aws-sdk'
require 'pp'

creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
ec2 = Aws::EC2::Client.new(region: 'us-west-2', credentials: creds)
iam = Aws::IAM::Client.new(region: 'us-west-2', credentials: creds)

owner_id = iam.get_user().to_h[:user][:arn].split(':')[4]

stats = {remove: 0, keep: 0, dead: 0}
volumes = Hash.new(0)
dead = Hash.new(0)

ec2.describe_snapshots({filters: [{name: 'owner-id', values: [owner_id]}]}).snapshots.each do |s|
  if s.start_time > Time.new('2016-12-31')
    stats[:remove] += 1
    volumes[s.volume_id] += 1
    if dead.has_key?(s.volume_id)
      dead[s.volume_id] += 1
      stats[:dead] += 1
    else
      begin
        ec2.describe_volumes({volume_ids: [s.volume_id]})
      rescue Aws::EC2::Errors::InvalidVolumeNotFound
        dead[s.volume_id] += 1
        stats[:dead] += 1
      end
    end
  else
    stats[:keep] += 1
  end
end

puts "Live Volumes: #{volumes.keys.count}"
puts "Dead Volumes: #{dead.keys.count}"
puts "Snapshots per volume: #{volumes.values.sort.reverse.first(10)}"

pp stats
