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

dash_id = ''
data = from_dog.get_dashboard(dash_id)

title = "System Overview"
description = "Overview of key system metrics"
graphs = data[1]['dash']['graphs']
template_variables = data[1]['dash']['template_variables']

puts "Creating System Overview Timeboard"

=begin
graphs = [
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.load.1{$env,$app,$role,$host,$name}",
      "conditional_formats" => [],
      "type" => "line"
    },
    {
      "q" =>
      "avg:system.load.5{$env,$app,$role,$host,$name}",
      "type" => "line"
    },
    {
      "q" =>
      "avg:system.load.15{$env,$app,$role,$host,$name}",
      "type" => "line"
    }], "markers" => [
    {
      "dim" => "y",
      "type" => "error dashed",
      "val" => 5,
      "value" => "y = 5",
      "label" =>
      "Load Average of 5"
    },
    {
      "dim" => "y",
      "type" => "warning dashed",
      "val" => 1,
      "value" => "y = 1",
      "label" =>
      "Load Average of 1"
    }]
  },
  "title" =>
  "System Load Average over all Hosts"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.load.1{$app,$role,$host,$name,$env} by {host}",
      "conditional_formats" => [],
      "type" => "line"
    },
    {
      "q" =>
      "avg:system.load.5{$app,$role,$host,$name,$env} by {host}",
      "type" => "line"
    },
    {
      "q" =>
      "avg:system.load.15{$app,$role,$host,$name,$env} by {host}",
      "type" => "line"
    }], "markers" => [
    {
      "dim" => "y",
      "type" => "error dashed",
      "val" => 5,
      "value" => "y = 5",
      "label" =>
      "Load Average of 5"
    },
    {
      "dim" => "y",
      "type" => "warning dashed",
      "val" => 1,
      "value" => "y = 1",
      "label" =>
      "Load Average of 1"
    }]
  },
  "title" => "System Load per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.idle{$env,$app,$role,$host,$name}, avg:system.cpu.system{$env,$app,$role,$host,$name}, avg:system.cpu.iowait{$env,$app,$role,$host,$name}, avg:system.cpu.user{$env,$app,$role,$host,$name}, avg:system.cpu.stolen{$env,$app,$role,$host,$name}, avg:system.cpu.guest{$env,$app,$role,$host,$name}",
      "conditional_formats" => [],
      "type" => "area"
    }], "yaxis" =>
    {
      "max" => 125, "min" => 0
    }
  },
  "title" =>
  "CPU Average Usage (%) over all Hosts"
},
{
  "definition" =>
  {
    "viz" => "toplist", "requests" => [
    {
      "q" =>
      "top(min:system.cpu.idle{$env,$app,$role,$host,$name} by {host}, 10, 'min', 'asc')",
      "style" =>
      {
        "palette" => "cool"
      },
      "conditional_formats" => []
    }]
  },
  "title" =>
  "Minimum CPU Idle over selected time window (by host)"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.idle{$env,$app,$role,$host,$name} by {host}, avg:system.cpu.system{$app,$role,$host,$name,$env} by {host}, avg:system.cpu.iowait{$app,$role,$host,$name,$env} by {host}, avg:system.cpu.user{$app,$role,$host,$name,$env} by {host}, avg:system.cpu.stolen{$app,$role,$host,$name,$env} by {host}, avg:system.cpu.guest{$app,$role,$host,$name,$env} by {host}",
      "conditional_formats" => [],
      "type" => "line",
      "style" =>
      {
        "width" => "normal"
      }
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" =>
  "Full CPU Usage per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.user{$env,$app,$role,$name} by {host}",
      "conditional_formats" => [],
      "type" => "line"
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" => "CPU User (%) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.system{$env,$app,$role,$name} by {host}",
      "conditional_formats" => [],
      "type" => "line"
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" =>
  "CPU System (%) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "max:system.cpu.iowait{$env,$app,$role,$host,$name} by {host} * 100",
      "conditional_formats" => [],
      "type" => "line"
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" => "I/O Wait (%) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.stolen{$env,$app,$role,$host,$name} by {host}",
      "conditional_formats" => [],
      "type" => "line"
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" =>
  "CPU Stolen (%) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.cpu.guest{$env,$app,$role,$host,$name} by {host}",
      "conditional_formats" => [],
      "type" => "area"
    }], "yaxis" =>
    {
      "max" => 110, "min" => 0
    }
  },
  "title" => "CPU Guest (%) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.mem.free{$app,$role,$host,$name,$env} by {host}, avg:system.mem.used{$app,$role,$host,$name,$env} by {host}, avg:system.mem.total{$app,$role,$host,$name,$env} by {host}",
      "conditional_formats" => [],
      "type" => "line"
    }]
  },
  "title" => "System Memory per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.net.bytes_rcvd{$app,$role,$host,$name,$env} by {host}",
      "style" =>
      {
        "palette" => "cool"
      },
      "type" => "area",
      "conditional_formats" => []
    },
    {
      "q" =>
      "0 - avg:system.net.bytes_sent{$app,$role,$host,$name,$env} by {host}",
      "style" =>
      {
        "palette" => "purple"
      },
      "type" => "area"
    }]
  },
  "title" =>
  "Network I/O (KB/s) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.mem.usable{$env,$app,$role,$host,$name}",
      "conditional_formats" => [],
      "type" => "line"
    },
    {
      "q" =>
      "avg:system.mem.total{$env,$app,$role,$host,$name}",
      "type" => "line"
    }]
  },
  "title" =>
  "Usable Memory vs. Total Memory"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.mem.pct_usable{$env,$app,$role,$host,$name} by {host} * 100",
      "conditional_formats" => [],
      "type" => "line"
    }], "markers" => [
    {
      "dim" => "y",
      "type" => "error dashed",
      "val" => 15,
      "value" => "y = 15",
      "label" => "Below 15%"
    }], "yaxis" =>
    {
      "max" => 100, "min" => 0
    }
  },
  "title" =>
  "% Memory Usable per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.io.rkb_s{$app,$role,$host,$name,$env} by {host}",
      "conditional_formats" => [],
      "type" => "area"
    },
    {
      "q" =>
      "0 - avg:system.io.rkb_s{$app,$role,$host,$name,$env} by {host}",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "area"
    }]
  },
  "title" =>
  "Disk R/W (KB/s) per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:system.io.r_s{$app,$role,$host,$name,$env} by {host}",
      "style" =>
      {
        "palette" => "cool"
      },
      "type" => "area",
      "conditional_formats" => []
    },
    {
      "q" =>
      "0 - avg:system.io.w_s{$app,$role,$host,$name,$env} by {host}",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "area"
    }]
  },
  "title" =>
  "Disk IO Read & Write / Second per Host"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:aws.elb.latency{$env,$app,$name} by {name} * sum:aws.elb.request_count{$env,$app,$name} by {name}",
      "conditional_formats" => [],
      "type" => "area"
    }]
  },
  "title" =>
  "# of In-Flight Request (per second)"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:aws.elb.latency{$env,$app,$name} * 1000, max:aws.elb.latency{$env,$app,$name} * 1000, min:aws.elb.latency{$env,$app,$name} * 1000",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "area",
      "conditional_formats" => []
    }]
  },
  "title" => "ELB Latency (ms)"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:aws.elb.httpcode_backend_2xx{$env,$app,$name} by {name}, avg:aws.elb.httpcode_backend_3xx{$env,$app,$name} by {name}",
      "conditional_formats" => [],
      "type" => "area"
    },
    {
      "q" =>
      "( 0 - avg:aws.elb.httpcode_backend_4xx{$env,$app,$name} by {name} ), ( 0 - avg:aws.elb.httpcode_backend_5xx{$env,$app,$name} by {name} )",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "area"
    }]
  },
  "title" =>
  "ELB Backend Return Code Distribution (per second)"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "sum:aws.elb.surge_queue_length{$env,$app,$name}, 0 - sum:aws.elb.spill_over_count{$env,$app,$name}",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "area",
      "conditional_formats" => []
    }], "markers" => [
    {
      "dim" => "y",
      "type" => "error dashed",
      "val" => 1024,
      "value" => "y = 1024",
      "label" =>
      "Max Surge Queue Depth"
    }]
  },
  "title" =>
  "ELB Surge Queue over Request Dropped"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "max:aws.elb.latency{$env,$app,$role,$name} by {availability-zone} * 1000",
      "style" =>
      {
        "palette" => "cool"
      },
      "type" => "bars",
      "conditional_formats" => []
    }]
  },
  "title" =>
  "Max ELB Latency by AZ (ms)"
},
{
  "definition" =>
  {
    "viz" => "timeseries", "requests" => [
    {
      "q" =>
      "avg:network.http.response_time{$env,$app,$name} by {url}",
      "style" =>
      {
        "palette" => "warm"
      },
      "type" => "line",
      "conditional_formats" => []
    }]
  },
  "title" =>
  "HTTP Response Time (Second)"
}]
=end

ret = to_dog.create_dashboard(title, description, graphs, template_variables)

if ret[0] == '200'
  puts "Timeboard created."
else
  puts "Failed to create timeboard. Returned: #{ret}"
end
