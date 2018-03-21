#! /usr/bin/ruby

def remove_certificate(nodename)
  begin
    system('/opt/puppetlabs/bin/puppet', 'cert', 'clean', 'username')
    system('/opt/puppetlabs/bin/puppet', 'node', 'purge', 'username')
  rescue => e
    puts "Error cleaning certificate #{nodename}: #{e.message}"
  end
end

def remove_environment(nodename)
  begin
    FileUtils.rm_rf "/etc/puppetlabs/code/#{nodename}".gsub("-","_")
  rescue => e
    puts "Error removing environment #{nodename}: #{e.message}"
  end
end

certificates = %x{puppet cert list --all}.each_line.map do |line|
  line = line.split[1].gsub('"', '')
  next if line.start_with? 'pe-internal'
  line
end.compact

containers = %x{docker ps}.each_line.map do |line|
  line = line.split.last
  next if line == 'NAMES'
  line
end.compact


 | awk '{print $2}' | sed 's/"//' }.each_line.reject {|cert| cert.start_with? 'pe-internal' }
containers = %x{docker ps -q}.each_line

containers.each_line do |container|
  container_info = JSON.parse(%x{docker inspect #{container}})[0]
  hostname = container_info['Config']['Hostname'].split('.')[0]
  starttime = DateTime.parse(container_info['State']['StartedAt'])
  stoptime = starttime + Rational(TIMEOUT.to_i, 86400)

  if DateTime.now > stoptime
    begin
      remove_environment(hostname)
      remove_certificate(hostname)
      remove_node_group(hostname)
      remove_container(container_info['Id'])
    rescue => e
      puts e
    end
  end
end