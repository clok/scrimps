# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

title = "System Overview"
description = "Overview of key system metrics"
graphs = [{
           "definition" => {
               "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.load.1{$env,$app,$role,$host}", "type" => "line"
                }, {
                    "q" => "avg:system.load.5{$env,$app,$role,$host}", "type" => "line"
                }, {
                    "q" => "avg:system.load.15{$env,$app,$role,$host}", "type" => "line"
                }], "markers" => [{
                    "dim" => "y", "type" => "error dashed", "value" => "y = 5", "val" => 5, "label" => "Load Average of 5"
                }, {
                    "dim" => "y", "type" => "warning dashed", "value" => "y = 1", "val" => 1, "label" => "Load Average of 1"
                }]
            }, "title" => "System load"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.cpu.iowait{$env,$app,$role,$host}", "type" => "line"
                }], "markers" => [{
                    "type" => "error dashed", "value" => "y = 25", "val" => "25", "label" => "IO Wait Above 25%"
                }]
            }, "title" => "CPU IOWait %"
        }, #{
           # "definition" => {
           #     "q" => "processes{$env,$app,$role,$host}", "viz" => "treemap", "group_by" => "family", "size_by" => "pct_mem", "color_by" => "user"
            #}, "title" => "Processes memory usage"
          #},
          {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.cpu.idle{$env,$app,$role,$host}, avg:system.cpu.system{$env,$app,$role,$host}, avg:system.cpu.iowait{$env,$app,$role,$host}, avg:system.cpu.user{$env,$app,$role,$host}, avg:system.cpu.stolen{$env,$app,$role,$host}, avg:system.cpu.guest{$env,$app,$role,$host}", "type" => "area"
                }], "yaxis" => {
                    "max" => 125, "min" => 0
                }
            }, "title" => "CPU usage (%)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "max:system.cpu.iowait{$env,$app,$role,$host} by {host} * 100", "type" => "line"
                }], "yaxis" => {
                    "max" => 125, "min" => 0
                }
            }, "title" => "I/O Wait (%) per Host"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.mem.free{$env,$app,$role,$host}, avg:system.mem.used{$env,$app,$role,$host}, avg:system.mem.total{$env,$app,$role,$host}", "type" => "line"
                }]
            }, "title" => "System memory"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.net.bytes_rcvd{$env,$app,$role,$host}", "style" => {
                        "palette" => "cool"
                    }, "type" => "area"
                }, {
                    "q" => "0 - avg:system.net.bytes_sent{$env,$app,$role,$host}", "style" => {
                        "palette" => "purple"
                    }, "type" => "area"
                }]
            }, "title" => "Network I/O (KB/s)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.mem.usable{$env,$app,$role,$host}", "type" => "line"
                }, {
                    "q" => "avg:system.mem.total{$env,$app,$role,$host}", "type" => "line"
                }]
            }, "title" => "Usable Memory vs. Total Memory"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.mem.pct_usable{$env,$app,$role,$host} by {host} * 100", "type" => "line"
                }], "markers" => [{
                    "type" => "error dashed", "value" => "y = 15", "val" => "15", "label" => "Below 15%"
                }], "yaxis" => {
                    "max" => 100, "min" => 0
                }
            }, "title" => "% Memory Usable per Host"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.io.rkb_s{$env,$app,$role,$host}", "type" => "area"
                }, {
                    "q" => "0 - avg:system.io.rkb_s{$env,$app,$role,$host}", "style" => {
                        "palette" => "warm"
                    }, "type" => "area"
                }]
            }, "title" => "Disk R/W (KB/s)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:system.io.r_s{$env,$app,$role,$host}", "style" => {
                        "palette" => "cool"
                    }, "type" => "area"
                }, {
                    "q" => "0 - avg:system.io.w_s{$env,$app,$role,$host}", "style" => {
                        "palette" => "warm"
                    }, "type" => "area"
                }]
            }, "title" => "Disk IO Read & Write / Second"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:aws.elb.latency{$env,$app} * sum:aws.elb.request_count{$env,$app}", "type" => "line"
                }]
            }, "title" => "# of In-Flight Request (per second)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:aws.elb.latency{$env,$app} * 1000, max:aws.elb.latency{$env,$app} * 1000, min:aws.elb.latency{$env,$app} * 1000", "style" => {
                        "width" => "normal", "palette" => "warm"
                    }, "type" => "line"
                }]
            }, "title" => "ELB Latency (ms)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "avg:aws.elb.httpcode_backend_2xx{$env,$app}, avg:aws.elb.httpcode_backend_3xx{$env,$app}", "type" => "area"
                }, {
                    "q" => "( 0 - avg:aws.elb.httpcode_backend_4xx{$env,$app} ), ( 0 - avg:aws.elb.httpcode_backend_5xx{$env,$app} )", "style" => {
                        "palette" => "warm"
                    }, "type" => "area"
                }]
            }, "title" => "ELB Backend Return Code Distribution (per second)"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "sum:aws.elb.surge_queue_length{$env,$app}, 0 - sum:aws.elb.spill_over_count{$env,$app}", "style" => {
                        "palette" => "warm"
                    }, "type" => "area"
                }], "markers" => [{
                    "type" => "error dashed", "value" => "y = 1024", "val" => "1024", "label" => "Max Surge Queue Depth"
                }]
            }, "title" => "ELB Surge Queue over Request Dropped"
        }, {
            "definition" => {
                "viz" => "timeseries", "requests" => [{
                    "q" => "max:aws.elb.latency{$env,$app,$role} by {availability-zone} * 1000", "style" => {
                        "palette" => "cool"
                    }, "type" => "bars"
                }]
            }, "title" => "Max ELB Latency by AZ (ms)"
        }]
template_variables = [{
            "default" => "env:production", "prefix" => "env", "name" => "env"
        }, {
            "default" => "*", "prefix" => "app", "name" => "app"
        }, {
            "default" => "*", "prefix" => "role", "name" => "role"
        }, {
            "default" => "*", "prefix" => "host", "name" => "host"
           }]

ret = dog.create_dashboard(title, description, graphs, template_variables)
puts ret
