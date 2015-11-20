require 'optparse'
require 'ostruct'
require 'yaml'

def opts
  dirname = File.dirname(__FILE__)
  @opts ||= OpenStruct.new(
                           msp_monthly: 12,
                           msp_hourly: 0.025,
                           base_monthly: 18,
                           base_hourly: 0.03,
                           paid_hosts: 30,
                           static_hosts: 30,
                           overages_cfg: File.expand_path("#{dirname}/overages.yml")
                          )
end

def option_parser
  @option_parser ||= OptionParser.new do |o|
    o.banner = "USAGE: #{$0} [options]"

    o.on("-p", "--pre-paid-hosts [NUMBER]. ",
         "Number of Monthly Pre Paid Hosts. DEFAULT: #{opts.paid_hosts}") do |h|
      opts.paid_hosts = h.to_i
    end

    o.on("-s", "--static-hosts [NUMBER]. ",
         "Number of static hosts in account. DEFAULT: #{opts.static_hosts}") do |h|
      opts.static_hosts = h.to_i
    end

    o.on("-o", "--overages [FILE]",
         "File containging overages definitions. DEFAULT: #{opts.overages_cfg}") do |h|
      opts.overages_cfg = h
    end

    o.on("--msp-monthly [NUMBER]",
         "MSP Monthly Rate. DEFAULT: #{opts.msp_monthly}") do |h|
      opts.msp_monthly = h.to_f
    end

    o.on("--msp-hourly [NUMBER]. ",
         "MSP Monthly Rate. DEFAULT: #{opts.msp_hourly}") do |h|
      opts.msp_hourly = h.to_f
    end

    o.on("--base-monthly [NUMBER]",
         "Base Monthly Rate. DEFAULT: #{opts.base_monthly}") do |h|
      opts.base_monthly = h.to_f
    end

    o.on("--base-hourly [NUMBER]. ",
         "Base Monthly Rate. DEFAULT: #{opts.base_hourly}") do |h|
      opts.base_hourly = h.to_f
    end

    
    o.on("-h", "--help", "Show this help documentation") do |h|
      STDERR.puts o
      STDERR.puts <<-EOF

overages.yml example:

---
- name: EMR 1
  hosts: 20
  hours: 4
  per_day: 1
- name: EMR 2
  hosts: 4
  hours: 3
  per_day: 4
EOF
      exit
    end
  end
end

option_parser.parse!

def calculate_metrics(msp_paid, base_paid, msp_daily_total, base_daily_total, paid_hosts, print_all)
  msp_monthly_over = msp_daily_total * 30
  base_monthly_over = base_daily_total * 30
  
  msp_monthly_total = msp_paid + msp_monthly_over
  base_monthly_total = base_paid + base_monthly_over

  output = []
  output.push(['PrePaid', 'MSP', 'DataDog', 'Overage', 'MSP', 'DataDog', 'Total', 'MSP', 'DataDog', 'Savings']) if print_all
  output.push([paid_hosts, msp_paid, base_paid, '', msp_monthly_over.round(2), base_monthly_over.round(2), '', msp_monthly_total.round(2), base_monthly_total.round(2), (base_monthly_total - msp_monthly_total).round(2)])
  
  puts "Monthly Summary (30 days, 720 hours)" if print_all
  output.each do |a|
    puts a.join("\t")
  end
end

def calculate_costs(rates, overages, paid_hosts, static_hosts, print_all)
  msp_paid = paid_hosts * rates[:msp][:static]
  base_paid = paid_hosts * rates[:base][:static]
  
  msp_daily_total = 0
  base_daily_total = 0
  
  output = [ ['Hour', 'Static', 'Hourly', 'Total', 'Overage', 'MSP', 'Base'] ]
  (0..23).each do |hour|
    data = [ hour, static_hosts ]
    extra_hosts = 0
    
    overages.each do |o|
      if (o['hours'] * o['per_day']) - hour > 0
        extra_hosts = extra_hosts + o['hosts']
      end
    end
    
    overage = [0, (static_hosts + extra_hosts) - paid_hosts].max
    
    total_hosts = static_hosts + extra_hosts
    msp_over = overage * rates[:msp][:hourly]
    base_over = overage * rates[:base][:hourly]
    
    data.push(extra_hosts, total_hosts, overage, msp_over.round(3), base_over.round(3))
    
    msp_daily_total = msp_daily_total + msp_over
    base_daily_total = base_daily_total + base_over
    
    output.push(data)
  end

  if print_all
    puts "Daily Breakdown"
    output.each do |a|

      puts a.join("\t")
    end
    puts
  end

  calculate_metrics(msp_paid, base_paid, msp_daily_total, base_daily_total, paid_hosts, print_all)
end

rates = {
         msp: { static: opts.msp_monthly, hourly: opts.msp_hourly },

         base: { static: opts.base_monthly, hourly: opts.base_hourly }
        }

# Number of hosts we opay for no matter what
paid_hosts = opts.paid_hosts

# Predicted static (runs all month) hosts
static_hosts = opts.static_hosts

# Predicted hourly overages
overages = YAML::load(File.open(opts.overages_cfg))

puts "Hosts Numbers"
puts "PrePaid Hosts\t#{paid_hosts}"
puts "Static Hosts\t#{static_hosts}"
puts

puts "Overages Entered"
puts ['Name','Hosts','Hours','Per Day'].join("\t")
overages.each do |o|
  puts o.keys.map {|k| o[k]}.join("\t")
end
puts

calculate_costs(rates, overages, paid_hosts, static_hosts, true)

(-2..2).each do |v|
  next if v == 0
  calculate_costs(rates, overages, paid_hosts + v, static_hosts, false)
end
