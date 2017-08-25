require 'rubygems'
require 'dogapi'
require 'json'
require 'ostruct'
require 'optparse'
require 'pp'

def opts
  @opts ||= OpenStruct.new(
    api_key: '',
    app_key: '',
    cluster: nil,
    title: nil,
    description: 'Generated App Dashboard',
    debug: false,
    dry_run: false
  )
end

def option_parser
  @option_parser ||= OptionParser.new do |o|
    o.banner = "USAGE: #{$0} [options]"

    o.on("-c", "--cluster [CLUSTER]", "REQUIRED: Example 'prod-1'") do |h|
      opts.cluster = h
    end

    o.on("-t", "--title [DASH_TITLE]", "Default: '<filter> Overview'") do |h|
      opts.title = h
    end

    o.on("-d", "--description [DASH_DESC]", "Default: #{opts.description}") do |h|
      opts.description = h
    end

    o.on("--api-key [API_KEY]", "Default: #{opts.api_key}") do |h|
      opts.api_key = h
    end

    o.on("--app-key [APP_KEY]", "Default: #{opts.app_key}") do |h|
      opts.api_key = h
    end

    o.on("-h", "--help", "Show help documentation") do |h|
      STDERR.puts o
      exit
    end
  end
end

option_parser.parse!

def info str
  $stdout.puts "[#{Time.now.strftime('%Y-%m-%d %T')}] #{str}"
end

def die str
  $stderr.puts "[#{Time.now.strftime('%Y-%m-%d %T')}] #{str}"
  exit 1
end

die('Filters required. Use -f flag') unless opts.cluster
dog = Dogapi::Client.new(opts.api_key, opts.app_key)
opts.title = "cluster-name:#{opts.cluster} Cluster Overview" unless opts.title

template_variables = [{"default"=>"*", "prefix"=>"host", "name"=>"host"}]

graphs = [{"definition"=>
   {"style"=>
     {"fillMax"=>nil,
      "palette"=>"green_to_orange",
      "fillMin"=>nil,
      "paletteFlip"=>true},
    "group"=>["cluster-name"],
    "noMetricHosts"=>true,
    "viz"=>"hostmap",
    "scope"=>["cluster-name:#{opts.cluster}"],
    "requests"=>
     [{"q"=>"avg:system.mem.pct_usable{cluster-name:#{opts.cluster}} by {host}",
       "type"=>"fill"},
      {"q"=>"avg:system.load.15{cluster-name:#{opts.cluster}} by {host}",
       "type"=>"size"}],
    "noGroupHosts"=>true},
  "title"=>"Host Map (load 15 vs % Mem Usable)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "sum:docker.mem.rss{$host,cluster-name:#{opts.cluster}} by {container_name}",
       "aggregator"=>"avg",
       "style"=>{"palette"=>"cool"},
       "type"=>"bars",
       "conditional_formats"=>[]}],
    "autoscale"=>true},
  "title"=>"Memory Used by Container by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>"avg:system.load.1{$host,cluster-name:#{opts.cluster}} by {host}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line"},
      {"q"=>"avg:system.load.5{$host,cluster-name:#{opts.cluster}} by {host}",
       "type"=>"line"},
      {"q"=>"avg:system.load.15{$host,cluster-name:#{opts.cluster}} by {host}",
       "type"=>"line"}],
    "autoscale"=>true,
    "markers"=>
     [{"type"=>"ok dashed",
       "val"=>"2",
       "value"=>"y = 2",
       "label"=>"Load Avg 2"},
      {"type"=>"warning dashed",
       "val"=>"5",
       "value"=>"y = 5",
       "label"=>"Load Avg 5"},
      {"type"=>"error dashed",
       "val"=>"10",
       "value"=>"y = 10",
       "label"=>"Load Avg 10"}]},
  "title"=>"System Load (1,5,15) by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "anomalies(max:system.load.1{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "aggregator"=>"avg",
       "style"=>{"palette"=>"grey"},
       "type"=>"line",
       "conditional_formats"=>[]},
      {"q"=>
        "anomalies(max:system.load.5{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "style"=>{"palette"=>"grey"},
       "type"=>"line"},
      {"q"=>
        "anomalies(max:system.load.15{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "style"=>{"palette"=>"grey"},
       "type"=>"line"}],
    "autoscale"=>true,
    "markers"=>
     [{"dim"=>"y",
       "type"=>"error dashed",
       "value"=>"y = 10",
       "val"=>10,
       "label"=>"Load Avg 10"},
      {"dim"=>"y",
       "type"=>"warning dashed",
       "value"=>"y = 5",
       "val"=>5,
       "label"=>"Load Avg 5"},
      {"dim"=>"y",
       "type"=>"ok dashed",
       "value"=>"y = 2",
       "val"=>2,
       "label"=>"Load Avg 2"}]},
  "title"=>"System Load (1,5,15) (Anomaly)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "sum:docker.containers.running{cluster-name:#{opts.cluster},$host} by {host}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"bars"}],
    "autoscale"=>true},
  "title"=>"# of Running Containers by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "anomalies(sum:docker.containers.running{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line",
       "style"=>{"palette"=>"grey"}}],
    "autoscale"=>true},
  "title"=>"# of Running Containers (Anomaly)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "sum:docker.cpu.throttled{$host,cluster-name:#{opts.cluster}} by {container_name,host}",
       "aggregator"=>"avg",
       "style"=>{"palette"=>"orange"},
       "type"=>"bars",
       "conditional_formats"=>[]}],
    "autoscale"=>true},
  "title"=>"Throttled Cycles by Container by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "requests"=>
     [{"q"=>
        "anomalies(sum:docker.cpu.throttled{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "style"=>{"palette"=>"grey"},
       "type"=>"line",
       "conditional_formats"=>[]}],
    "autoscale"=>true},
  "title"=>"Throttled CPU Cycles (Anomaly)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "avg:system.cpu.idle{$host,cluster-name:#{opts.cluster}}, avg:system.cpu.system{$host,cluster-name:#{opts.cluster}}, avg:system.cpu.iowait{$host,cluster-name:#{opts.cluster}}, avg:system.cpu.user{$host,cluster-name:#{opts.cluster}}, avg:system.cpu.stolen{$host,cluster-name:#{opts.cluster}}, avg:system.cpu.guest{$host,cluster-name:#{opts.cluster}}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"area"}],
    "autoscale"=>true,
    "yaxis"=>{"max"=>125, "min"=>0}},
  "title"=>"CPU Profile by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "anomalies(avg:system.cpu.idle{$host,cluster-name:#{opts.cluster}}, 'basic', 3), anomalies(avg:system.cpu.system{$host,cluster-name:#{opts.cluster}}, 'basic', 3), anomalies(avg:system.cpu.iowait{$host,cluster-name:#{opts.cluster}}, 'basic', 3), anomalies(avg:system.cpu.user{$host,cluster-name:#{opts.cluster}}, 'basic', 3), anomalies(avg:system.cpu.stolen{$host,cluster-name:#{opts.cluster}}, 'basic', 3), anomalies(avg:system.cpu.guest{$host,cluster-name:#{opts.cluster}}, 'basic', 3)",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line",
       "style"=>{"palette"=>"grey"}}],
    "autoscale"=>true,
    "yaxis"=>{"max"=>125, "min"=>0}},
  "title"=>"CPU Profile (Anomaly)"},
 {"definition"=>
   {"status"=>"done",
    "autoscale"=>true,
    "yaxis"=>{"max"=>100, "min"=>0},
    "markers"=>
     [{"dim"=>"y",
       "type"=>"warning dashed",
       "val"=>15,
       "value"=>"y = 15",
       "label"=>"Below 15%"},
      {"dim"=>"y",
       "type"=>"error dashed",
       "val"=>10,
       "value"=>"y = 10",
       "label"=>"Below 10%"},
      {"dim"=>"y", "type"=>"info dashed", "val"=>100, "value"=>"y = 100"}],
    "viz"=>"timeseries",
    "requests"=>
     [{"q"=>
        "avg:system.mem.pct_usable{$host,cluster-name:#{opts.cluster}} by {host} * 100",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line"}]},
  "title"=>"Memory Usable % by Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "anomalies(min:system.mem.pct_usable{cluster-name:#{opts.cluster},$host}, 'basic', 3)",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line",
       "style"=>{"palette"=>"grey"}}],
    "autoscale"=>true,
    "markers"=>
     [{"type"=>"info dashed", "val"=>"1", "value"=>"y = 1"},
      {"type"=>"warning dashed", "val"=>".15", "value"=>"y = .15"},
      {"type"=>"error dashed", "val"=>".10", "value"=>"y = .10"}]},
  "title"=>"Memory Usable % (Anomaly)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "max:system.disk.in_use{$host,cluster-name:#{opts.cluster}} by {device,host}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line"}],
    "autoscale"=>true,
    "markers"=>
     [{"dim"=>"y", "type"=>"error dashed", "val"=>1, "value"=>"y = 1"},
      {"max"=>1,
       "min"=>0.95,
       "type"=>"error dashed",
       "value"=>".95 < y < 1",
       "dim"=>"y"},
      {"max"=>0.95,
       "min"=>0.8,
       "type"=>"warning dashed",
       "value"=>".80 < y < .95",
       "dim"=>"y"}]},
  "title"=>"Disk % Usage by Device & Host"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "avg:system.mem.free{$host,cluster-name:#{opts.cluster}} by {host}, avg:system.mem.used{$host,cluster-name:#{opts.cluster}} by {host}, avg:system.mem.total{$host,cluster-name:#{opts.cluster}} by {host}, avg:system.mem.usable{$host,cluster-name:#{opts.cluster}} by {host}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"line"}],
    "autoscale"=>true},
  "title"=>"Memory Usage Profile"},
 {"definition"=>
   {"status"=>"done",
    "autoscale"=>true,
    "yaxis"=>{"max"=>110, "min"=>0},
    "markers"=>[{"type"=>"info dashed", "val"=>"100", "value"=>"y = 100"}],
    "viz"=>"timeseries",
    "requests"=>
     [{"q"=>
        "avg:system.cpu.stolen{$host,cluster-name:#{opts.cluster}} by {host}, avg:system.cpu.iowait{$host,cluster-name:#{opts.cluster}} by {host}, avg:system.cpu.guest{$host,cluster-name:#{opts.cluster}} by {host}",
       "aggregator"=>"avg",
       "conditional_formats"=>[],
       "type"=>"area",
       "style"=>{"palette"=>"warm"}}]},
  "title"=>"Bad CPU Usage (Stolen, IO Wait, Guest)"},
 {"definition"=>
   {"viz"=>"change",
    "status"=>"done",
    "requests"=>
     [{"extra_col"=>"",
       "change_type"=>"absolute",
       "order_dir"=>"desc",
       "compare_to"=>"hour_before",
       "q"=>"max:system.cpu.user{cluster-name:#{opts.cluster},$host} by {host}",
       "increase_good"=>false,
       "order_by"=>"change"}]},
  "title"=>"Change in CPU Usage (User)"},
 {"definition"=>
   {"viz"=>"toplist",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "top(avg:system.cpu.idle{cluster-name:#{opts.cluster},$host} by {name}, 50, 'min', 'asc')",
       "style"=>{"palette"=>"cool"},
       "conditional_formats"=>[]}]},
  "title"=>"Top 50 Average CPU Idle Time"},
 {"definition"=>
   {"viz"=>"toplist",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "top(max:system.cpu.user{cluster-name:#{opts.cluster},$host} by {host}, 50, 'mean', 'desc')",
       "style"=>{"palette"=>"dog_classic"},
       "conditional_formats"=>[]}]},
  "title"=>"Top CPU Usage (User)"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "0 - avg:kubernetes.network.tx_bytes{$host,cluster-name:#{opts.cluster}} by {name}",
       "aggregator"=>"avg",
       "style"=>{"palette"=>"warm"},
       "type"=>"area",
       "conditional_formats"=>[]},
      {"q"=>
        "avg:kubernetes.network.rx_bytes{$host,cluster-name:#{opts.cluster}} by {name}",
       "style"=>{"palette"=>"cool"},
       "type"=>"area"}],
    "autoscale"=>true},
  "title"=>"Kubernetes Network I/O"},
 {"definition"=>
   {"viz"=>"timeseries",
    "status"=>"done",
    "requests"=>
     [{"q"=>
        "anomalies(max:kubernetes.network.tx_bytes{cluster-name:#{opts.cluster},$host}, 'basic', 3), anomalies(max:kubernetes.network.rx_bytes{cluster-name:#{opts.cluster},$host}, 'basic', 3)",
       "aggregator"=>"avg",
       "style"=>{"palette"=>"grey"},
       "type"=>"line",
       "conditional_formats"=>[]}],
    "autoscale"=>true},
  "title"=>"Kubernetes Network I/O (Anomaly)"}]

info "Generating - Title: #{opts.title} Desc: #{opts.description}"

ret = dog.create_dashboard(opts.title, opts.description, graphs, template_variables)

if ret[0] == '200'
  info "Dashboard created."
else
  die "Failed to create timeboard. Returned: #{ret}"
end
