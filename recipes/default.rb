#
# Cookbook Name:: iptables
# Recipe:: default
#
# Copyright 2016, redborder
#
# AFFERO GENERAL PUBLIC LICENSE, Version 3
#

iptables_config "config" do
  mystring "test"
  action :add
end
