#
# Cookbook Name:: splunk-unix-app
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe 'chef-vault'

splunk_auth_info = chef_vault_item(:vault, "splunk_#{node.chef_environment}")['auth']

cookbook_file "splunk-add-on-for-unix-and-linux_502.tgz" do
	path "/tmp/splunk-add-on-for-unix-and-linux_502.tgz"
	action :create_if_missing	
end

execute "expand_app_tarball" do
	cwd					"/opt/splunkforwarder/etc/apps"
	command			"tar -zxvf /tmp/splunk-add-on-for-unix-and-linux_502.tgz"
	creates 		"/opt/splunkforwarder/etc/apps/Splunk_TA_nix/bin/setup.sh"
	notifies	:run, "execute[patch_unix_app_setup]"
end

execute "patch_unix_app_setup" do
	action :nothing
	command 'sed -i "s/^#\!\/bin\/sh$/#\!\/bin\/bash/" /opt/splunkforwarder/etc/apps/Splunk_TA_nix/bin/setup.sh'
	notifies	:run, "execute[enable_nix_scripted_inputs]"
end

directory "/usr/local/nictool/server" do
	action	:create
	
end

execute "enable_nix_scripted_inputs" do
	env 		({ "HOME" => "/tmp" })
	command "/opt/splunkforwarder/bin/splunk login -auth #{splunk_auth_info}; /opt/splunkforwarder/bin/splunk cmd /opt/splunkforwarder/etc/apps/Splunk_TA_nix/bin/setup.sh --enable-all --auth #{splunk_auth_info}"
	action	:nothing
	notifies	:restart, "service[splunk]", :delayed
end

