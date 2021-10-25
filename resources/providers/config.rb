# Cookbook Name:: iptables
# 
# Provider:: config
#

require 'netaddr'

action :add do #Usually used to install and configure something
  begin
    config_dir = new_resource.config_dir

    manager             =
    nodes               = []

    virtual_ips         = {}
    manager_enabled     = (node["redborder"]["manager"]["status"] == "enabled" or node["redborder"]["manager"]["status"].nil?)
    manager_services    = {}
    cloudproxy_nodes    = []
    flow_nodes          = []


    # Código que clasifica los distintos nodos según el tipo de sensor.
    manager, nodes, cloudproxy_nodes, flow_nodes = clasify_nodes

    # Internal bond variables
    ipsync=nil
    netsync=nil
    ifsync=nil
    masksync=nil

    ipsync, netsync, ifsync, masksync = get_sync

    # Management bond variables
    ipmgt=nil
    netmgt=nil
    ifmgt=nil
    maskmgt=nil

    ipmgt, netmgt, ifmgt, maskmgt = get_mgt

    # Install iptables service.
    package 'Install iptables' do
      case node[:platform]
      when 'centos'
        package_name 'iptables-services'
      end
    end

    # Template for iptables sysconfig.
    template "#{config_dir}/iptables" do
      source "iptables_config.erb"
      owner "root"
      group "root"
      cookbook "iptables"
      mode 0600
      variables(:manager => manager, :sensors => nodes, :balanced_services => node["redborder"]["manager"]["balanced"], :cloudproxy_nodes => cloudproxy_nodes, :flow_nodes => flow_nodes, :ifsync => ifsync, :netsync => netsync, :netmgt => netmgt, :ifmgt => ifmgt)
      notifies :reload, 'service[iptables]', :delayed
    end

    # Enable and start the iptables service
    service "iptables" do
      supports :status => true, :start => true, :restart => true, :reload => true, :stop => true
      action [:start, :enable]
    end

    Chef::Log.info("Iptables cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do #Usually used to uninstall something
  begin
    config_dir = new_resource.config_dir

    service "iptables" do
      supports :stop => true, :disable => true
      action [:stop, :disable]
    end
    # Delete iptables config file
    # template "#{config_dir}/iptables" do
    #   action :delete
    #   backup false
    # end

    # Uninstall iptables service.
    # package 'Uninstall iptables' do
    #   case node[:platform]
    #   when 'centos'
    #     package_name 'iptables-services'
    #   end
    #   action :remove
    # end

    Chef::Log.info("Iptables cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do #Usually used to register in consul
  begin
    if !node["iptables"]["registered"]
      query = {}
      query["ID"] = "iptables-#{node["hostname"]}"
      query["Name"] = "iptables"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 0
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["iptables"]["registered"] = true
    end
    Chef::Log.info("Iptables service has been registered in consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do #Usually used to deregister from consul
  begin
    if node["iptables"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/iptables-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["iptables"]["registered"] = false
    end
    Chef::Log.info("Iptables service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
