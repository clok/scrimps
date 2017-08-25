# Make sure you replace the API and/or APP key below
# with the ones for your account

require 'rubygems'
require 'dogapi'

api_key=''
app_key=''

dog = Dogapi::Client.new(api_key, app_key)

board = {
  "board_title" => "RDS - Status", "board_bgtype" => "board_graph", "original_title" => "RDS - Status", "height" => 162, "width" => "100%", "template_variables" => [{
    "default" => "*", "prefix" => "dbinstanceidentifier", "name" => "instance"
  }, {
    "default" => "env:production", "prefix" => "env", "name" => "env"
  }], "templated" => true, "widgets" => [{
    "metric" => "aws.rds.replica_lag", "height" => 11, "query" => "max:aws.rds.replica_lag{$instance,$env}", "text_size" => "auto", "unit" => "auto", "title_size" => 13, "title" => true, "aggregator" => "max", "title_align" => "center", "text_align" => "center", "width" => 22, "timeframe" => "1h", "type" => "query_value", "tags" => ["$instance", "$env"], "precision" => 2, "title_text" => "Max replica lag past hour (s)", "x" => 35, "metric_type" => "standard", "conditional_formats" => [], "is_valid_query" => true, "res_calc_func" => "raw", "aggr" => "max", "y" => 0, "calc_func" => "raw"
  }, {
    "metric" => "", "height" => 11, "query" => "1000*max:aws.rds.read_latency{$instance,$env}", "text_size" => "auto", "unit" => "auto", "title_size" => 13, "title" => true, "aggregator" => "max", "title_align" => "center", "text_align" => "center", "width" => 20, "timeframe" => "1h", "type" => "query_value", "tags" => [], "precision" => 2, "title_text" => "Max read latency past hour (ms)", "x" => 59, "metric_type" => "standard", "conditional_formats" => [], "is_valid_query" => false, "res_calc_func" => "raw", "aggr" => "avg", "y" => 0, "calc_func" => "raw"
  }, {
    "metric" => "", "height" => 11, "query" => "1000*max:aws.rds.write_latency{$instance,$env}", "text_size" => "auto", "unit" => "auto", "title_size" => 13, "title" => true, "aggregator" => "max", "title_align" => "center", "text_align" => "center", "width" => 20, "timeframe" => "1h", "type" => "query_value", "tags" => [], "precision" => 2, "title_text" => "Max write latency past hour (ms)", "x" => 81, "metric_type" => "standard", "conditional_formats" => [], "is_valid_query" => false, "res_calc_func" => "raw", "aggr" => "avg", "y" => 0, "calc_func" => "raw"
  }, {
    "metric" => "aws.rds.read_iops", "height" => 11, "query" => "avg:aws.rds.read_iops{$instance,$env}", "text_size" => "auto", "unit" => "auto", "title_size" => 13, "title" => true, "aggregator" => "avg", "title_align" => "center", "text_align" => "center", "width" => 20, "timeframe" => "1h", "type" => "query_value", "tags" => ["$instance", "$env"], "precision" => 2, "title_text" => "Avg read ops per second, past hour", "x" => 103, "metric_type" => "standard", "conditional_formats" => [], "is_valid_query" => true, "res_calc_func" => "raw", "aggr" => "avg", "y" => 0, "calc_func" => "raw"
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Replication lag", "y" => 14, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Replication lag by instance (s), top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10(avg:aws.rds.replica_lag{$instance,$env} by {dbinstanceidentifier})", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 14, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Connections by instance, top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10(max:aws.rds.database_connections{$instance,$env} by {dbinstanceidentifier})", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 30, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "sizing" => "zoom", "title_size" => 16, "title" => true, "url" => "/static/images/screenboard/integrations/amazon_rds.png", "title_align" => "left", "title_text" => "", "height" => 13, "width" => 33, "y" => 0, "x" => 0, "type" => "image"
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Replication lag by instance (s, avg) past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.replica_lag{$instance,$env} by {dbinstanceidentifier}, 10, 'max', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 14, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Connections", "y" => 30, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Replication lag by instance (s), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.replica_lag{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 14, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Connections by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(max:aws.rds.database_connections{$instance,$env} by {dbinstanceidentifier}, 10, 'max', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 30, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Connections by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "max:aws.rds.database_connections{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 30, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "CPU by instance (%), top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10(avg:aws.rds.cpuutilization{$instance,$env} by {dbinstanceidentifier})", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 46, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Compute", "y" => 46, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "CPU by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.cpuutilization{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 46, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "CPU by instance (%), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.cpuutilization{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 46, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Read Operations", "y" => 62, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read operations per second by instance, top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10(avg:aws.rds.read_iops{$instance,$env} by {dbinstanceidentifier})", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 62, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read operations per second by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.read_iops{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 62, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read operations per second by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.read_iops{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 62, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Read Latency", "y" => 78, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read Latency by instance (ms), top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10( 1000 * avg:aws.rds.read_latency{$instance,$env} by {dbinstanceidentifier} )", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 78, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read latency by instance (ms), past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.read_latency{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 78, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Read latency by instance (ms), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "1000 * avg:aws.rds.read_latency{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 78, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Write Operations", "y" => 94, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write operations per second by instance, top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10(avg:aws.rds.write_iops{$instance,$env} by {dbinstanceidentifier})", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 94, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write operations per second by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.write_iops{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 94, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write operations per second by instance, past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.write_iops{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 94, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Write Latency", "y" => 110, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write Latency by instance (ms), top 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "top10( 1000 * avg:aws.rds.write_latency{$instance,$env} by {dbinstanceidentifier} )", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 110, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write latency by instance (ms), past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.write_latency{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 110, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Write latency by instance (ms), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "1000 * avg:aws.rds.write_latency{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 110, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available RAM by instance (Bytes), bottom 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "avg:aws.rds.freeable_memory{$instance,$env} by {dbinstanceidentifier}", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 126, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "RAM", "y" => 126, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available RAM by instance (bytes), past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.freeable_memory{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 126, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available RAM by instance (Bytes), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.freeable_memory{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 126, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available Disk by instance (Bytes), bottom 10 past day", "height" => 13, "tile_def" => {
      "viz" => "timeseries", "requests" => [{
        "q" => "avg:aws.rds.free_storage_space{$instance,$env} by {dbinstanceidentifier}", "type" => "line"
      }]
    }, "width" => 43, "timeframe" => "1d", "y" => 142, "x" => 14, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "refresh_every" => 30000, "tick_pos" => "50%", "title_align" => "left", "tick_edge" => "right", "text_align" => "center", "title_text" => "", "height" => 15, "bgcolor" => "blue", "html" => "Disk", "y" => 142, "x" => 0, "font_size" => "14", "tick" => true, "type" => "note", "width" => 12, "auto_refresh" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available Disk by instance (bytes), past day", "height" => 13, "tile_def" => {
      "viz" => "toplist", "requests" => [{
        "q" => "top(avg:aws.rds.free_storage_space{$instance,$env} by {dbinstanceidentifier}, 10, 'mean', 'desc')", "style" => {
          "palette" => "dog_classic"
        }, "conditional_formats" => []
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 142, "x" => 59, "legend_size" => "0", "type" => "toplist", "legend" => false
  }, {
    "title_size" => 16, "title" => true, "title_align" => "left", "title_text" => "Available Disk by instance (Bytes), past day", "height" => 13, "tile_def" => {
      "viz" => "heatmap", "requests" => [{
        "q" => "avg:aws.rds.free_storage_space{$instance,$env} by {dbinstanceidentifier}"
      }]
    }, "width" => 42, "timeframe" => "1d", "y" => 142, "x" => 103, "legend_size" => "0", "type" => "timeseries", "legend" => false
  }, {
    "metric" => "aws.rds.write_iops", "height" => 11, "query" => "avg:aws.rds.write_iops{$instance,$env}", "text_size" => "auto", "unit" => "auto", "title_size" => 13, "title" => true, "aggregator" => "avg", "title_align" => "center", "text_align" => "center", "width" => 20, "timeframe" => "1h", "type" => "query_value", "tags" => ["$instance", "$env"], "precision" => 2, "title_text" => "Avg write ops per second, past hour", "x" => 125, "metric_type" => "standard", "conditional_formats" => [], "is_valid_query" => true, "res_calc_func" => "raw", "aggr" => "avg", "y" => 0, "calc_func" => "raw"
  }]
}

ret = dog.create_screenboard(board)
puts ret
