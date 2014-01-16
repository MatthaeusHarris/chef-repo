default[:splunkforwarder][:forward_server] = 		"splunk:9997"
default[:splunkforwarder][:home] =					"/opt/splunkforwarder"
default[:splunkforwarder][:bin] = 					"/opt/splunkforwarder/bin/splunk"
default[:splunkforwarder][:inputs][:chef_log] =		{:file => "/var/log/chef/client.log",
											:index => "chef"}
default[:splunkforwarder][:admin][:username] = 		"admin"
default[:splunkforwarder][:admin][:password] = 		"blarg"											