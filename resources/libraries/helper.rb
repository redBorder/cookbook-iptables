require 'netaddr'

# Function that clasify the sensors
#
def clasify_nodes
  manager             =
  nodes               = []
  cloudproxy_nodes    = []
  flow_nodes          = []

  manager_keys = Chef::Node.list.keys.sort
  manager_keys.each do |m_key|
    m = Chef::Node.load m_key
    m = node if m.name == node.name
    manager = node if m.name == node.name

    begin
      roles = m.roles
    rescue NoMethodError
      begin
        roles = m.run_list
      rescue
        roles = []
      end
    end

    unless roles.nil?
      if !roles.empty?
        if roles.include?("ips-sensor") or roles.include?("ipsv2-sensor") or roles.include?("ipscp-sensor")
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"flow-sensor"
          nodes << m
          flow_nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"social-sensor"
          nodes << m
        elsif  m.respond_to?"run_list" and (m.run_list.map{|x| x.name}.include?"vault-sensor" or m.run_list.map{|x| x.name}.include?"cep-sensor")
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"mse-sensor"
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"ale-sensor"
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"device-sensor"
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"meraki-sensor"
          nodes << m
        elsif m.respond_to?"run_list" and m.run_list.map{|x| x.name}.include?"cisco-cloudproxy"
          nodes << m
          cloudproxy_nodes << m
        end
      end
    end
  end

  return manager, nodes, cloudproxy_nodes, flow_nodes
end

# Function that fills the variables ipsync, netsync, ifsync, masksync
#
def get_sync
  ipsync=nil
  netsync=nil
  ifsync=nil
  masksync=nil

  [ node["redborder"]["manager"]["internal_bond"], node["redborder"]["manager"]["management_bond"] ].each do |iface|
    unless iface.nil?
      unless node["network"]["interfaces"][iface].nil?
        unless node["network"]["interfaces"][iface]["addresses"].nil?
          node["network"]["interfaces"][iface]["addresses"].each do |x|
            if x[1]["family"]=="inet" and ipsync.nil? and !x[1]["prefixlen"].nil? and x[1]["prefixlen"] != "32"
              ipsync=x[0]
              netsync=NetAddr::CIDR.create("#{ipsync}/#{x[1]["prefixlen"]}").to_s
              ifsync=iface
              masksync=x[1]["prefixlen"]
              break
            end
          end
        end
      end
    end
  end

  if (ipsync.nil? or masksync.nil? or netsync.nil? or ifsync.nil? or ipsync=="" or masksync=="" or netsync=="" or ifsync=="") and !node["redborder"]["manager"].nil? and !node["redborder"]["manager"]["internal_bond"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["ip"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["prefixlen"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["net"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["iface"].nil? and node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["ip"] != "127.0.0.1"
    ipsync=node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["ip"]
    masksync=node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["prefixlen"]
    netsync=node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["net"]
    ifsync=node["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["iface"]
  else
    if ipsync.nil?
      ipsync="127.0.0.1"
      netsync="127.0.0.0/24"
      ifsync="lo"
      masksync="32"
    end

    node.set["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["ip"]=ipsync
    node.set["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["prefixlen"]=masksync
    node.set["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["net"]=netsync
    node.set["redborder"]["manager"][node["redborder"]["manager"]["internal_bond"]]["iface"]=ifsync
  end

  return ipsync, netsync, ifsync, masksync
end


# Function that fills the variables ipmgt, netmgt, ifmgt, maskmgt
#
def get_mgt
  ipmgt=nil
  netmgt=nil
  ifmgt=nil
  maskmgt=nil

  [ node["redborder"]["manager"]["management_bond"], node["redborder"]["manager"]["internal_bond"] ].each do |iface|
    unless iface.nil?
      unless node["network"]["interfaces"][iface].nil?
        unless node["network"]["interfaces"][iface]["addresses"].nil?
          node["network"]["interfaces"][iface]["addresses"].each do |x|
            if x[1]["family"]=="inet" and ipmgt.nil? and !x[1]["prefixlen"].nil? and x[1]["prefixlen"] != "32"
              ipmgt=x[0]
              netmgt=NetAddr::CIDR.create("#{ipmgt}/#{x[1]["prefixlen"]}").to_s
              ifmgt=iface
              maskmgt=x[1]["prefixlen"]
              break
            end
          end
        end
      end
    end
  end

  if (ipmgt.nil? or maskmgt.nil? or netmgt.nil? or ifmgt.nil? or ipmgt=="" or maskmgt=="" or netmgt=="" or ifmgt=="") and !node["redborder"].nil? and !node["redborder"]["dmidecode"].nil? and !node["redborder"]["dmidecode"]["manufacturer"].nil? and node["redborder"]["iscloud"] and !node["redborder"]["manager"].nil? and !node["redborder"]["manager"]["management_bond"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["ip"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["prefixlen"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["net"].nil? and !node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["iface"].nil? and node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["ip"] != "127.0.0.1"
    ipmgt=node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["ip"]
    maskmgt=node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["prefixlen"]
    netmgt=node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["net"]
    ifmgt=node["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["iface"]
  else
    if ipmgt.nil?
      ipmgt="127.0.0.1"
      netmgt="127.0.0.0/24"
      ifmgt="lo"
      maskmgt="32"
    end

    node.set["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["ip"]=ipmgt
    node.set["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["prefixlen"]=maskmgt
    node.set["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["net"]=netmgt
    node.set["redborder"]["manager"][node["redborder"]["manager"]["management_bond"]]["iface"]=ifmgt
  end

  return ipmgt, netmgt, ifmgt, maskmgt
end