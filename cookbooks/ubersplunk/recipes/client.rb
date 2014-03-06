#
# Cookbook Name:: ubersplunk
# Recipe:: client
#
# Copyright 2014, Matt Harris
#

include_recipe 'chef-vault'

splunk_auth_info = chef_vault_item(:vault, "splunk_#{node.chef_environment}")['auth']

nix_app_inputs = [
	"cpu.sh",
	"df.sh",
	"hardware.sh",
	"interfaces.sh",
	"iostat.sh",
	"lastlog.sh",
	"lsof.sh",
	"netstat.sh",
	"openPorts.sh",
	"openPortsEnhanced.sh",
	"package.sh",
	"passwd.sh",
	"protocol.sh",
	"ps.sh",
	"rlog.sh",
	"service.sh",
	"sshdChecker.sh",
	"time.sh",
	"top.sh",
	"update.sh",
	"uptime.sh",
	"usersWithLoginPrivs.sh",
	"version.sh",
	"vmstat.sh",
	"who.sh",
	"/var/log"
]

[
	{
		:app => "Splunk_TA_nix",
		:cookbook_file => "splunk-add-on-for-unix-and-linux_502.tgz"
	}
].each do |app|
	splunk_app app[:app] do
		action			[:install, :enable]
		app_name		app[:app]
		cookbook_file	app[:cookbook_file]
		splunk_auth 	splunk_auth_info
		enabled			true
		installed		true
		notifies	:run, "execute[patch_unix_app_setup]", :immediately
		notifies		:restart, 'service[splunk]', :delayed
	end
end

execute "patch_unix_app_setup" do
	# action :nothing
	command 'sed -i "s/^#\!\/bin\/sh$/#\!\/bin\/bash/" /opt/splunkforwarder/etc/apps/Splunk_TA_nix/bin/setup.sh'
	nix_app_inputs.each do |input|	
		notifies	:run, "execute[enable_#{input}]", :immediately
	end
end

nix_app_inputs.each do |input|
	execute "enable_#{input}" do
		env 		({ 
						"HOME" => "/tmp",
						"server_app_name" => "Splunk_TA_nix"
					})
		command 	"/opt/splunkforwarder/bin/splunk cmd /opt/splunkforwarder/etc/apps/Splunk_TA_nix/bin/setup.sh --enable-input #{input} --auth #{splunk_auth_info}"
		# action		:nothing
		notifies	:restart, 'service[splunk]', :delayed
	end
end

execute "debug_shit" do
	command		"/opt/splunkforwarder/bin/splunk display app -auth #{splunk_auth_info}"
end