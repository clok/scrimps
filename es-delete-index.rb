cmd = "curl 'http://logs.toneitup.com/_cat/indices/cwl-*?s=index&h=index'"
`#{cmd}`.split("\n").each do |l|
  puts "curl -XDELETE http://logs.toneitup.com/#{l}"
end
