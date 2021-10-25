#Flags
default["iptables"]["registered"]               = false

# Balanced services
default["redborder"]["manager"]["balanced"]     = [ {:port => 443, :protocol => "tcp", :name => "erchef service", :service => "erchef", :redirected_service=> "nginx", :persistence_timeout => 9600}, {:port => 443, :protocol => "tcp", :name => "s3 cloud storage", :service => "riak", :redirected_service=> "nginx", :persistence_timeout => 9600}, {:port => 443, :protocol => "tcp", :name => "redBorder WEBUI", :service => "rb-webui", :redirected_service=> "nginx", :persistence_timeout => 9600}, {:port => 2055, :protocol => "udp", :name => "netflow,ipfix/sflow daemon", :service => "nprobe", :redirected_service=> "nprobe", :persistence_timeout => 30}, {:port => 162, :protocol => "udp", :name => "net-snmp trap daemon", :service => "trap2kafka", :redirected_service=> "trap2kafka", :persistence_timeout => 30}, {:port => 2057, :protocol => "tcp", :name => "network stream to kafka - rb_loc topic", :service => "n2klocd", :redirected_service=> "n2klocd", :persistence_timeout => 30}, {:port => 5050, :protocol => "tcp", :name => "network stream to kafka - rb_mobile topic", :service => "n2kmobiled", :redirected_service=> "n2kmobiled", :persistence_timeout => 30}, {:port => 1813, :protocol => "udp", :name => "radius accounting", :service => "freeradius", :redirected_service=> "freeradius", :persistence_timeout => 30}, {:port => 6343, :protocol => "udp", :name => "sflow daemon", :service => "sfacctd", :redirected_service=> "sfacctd", :persistence_timeout => 30}, {:port => 69, :protocol => "udp", :name => "xinetd/tftp daemon", :service => "xinetd", :redirected_service=> "xinetd", :persistence_timeout => 30} ]

# Virtual_ips services for internal and external
default["redborder"]["manager"]["virtual_ips"]     = { :internal => [ {:service => "cep"}, {:service => "riak", "deps" => ["nginx"] }, {:service => "erchef", "deps" => ["nginx"]}, {:service => "postgresql"}, {:service => "n2kmetricd"}, {:service => "zookeeper2"}, {:service => "kafka"}, {:service => "oozie"}, {:service => "hadoop_resourcemanager"}, {:service => "hadoop_namenode"}, {:service => "drill"} ], :external => [ {:service => "rb-webui", "deps" => ["nginx"]}, {:service => "riak", "deps" => ["nginx"] }, {:service => "erchef", "deps" => ["nginx"]}, {:service => "kafka"}, {:service => "nprobe"}, {:service => "trap2kafka"}, {:service => "n2klocd"}, {:service => "n2kmobiled"}, {:service => "freeradius"}, {:service => "sfacctd"}, {:service => "xinetd"} ] }

# Actual status of the manager
default["redborder"]["manager"]["status"]             = "enabled"

# Internal and management bond name
default["redborder"]["manager"]["management_bond"]    = "bond0"
default["redborder"]["manager"]["internal_bond"]      = "bond1"

# Nginx extra ports
default["redborder"]["nginx"]["extra_ports"]   = []