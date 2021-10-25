# Cookbook Name:: iptables
#
#  Resource:: config
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, :kind_of => String, :default => "/etc/sysconfig"
