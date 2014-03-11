#
# Cookbook Name:: ubersplunk
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe 'chef-vault'

splunk_auth_info = chef_vault_item(:vault, "splunk_#{node.chef_environment}")['auth']

apt_package "sysstat" do
	action	:install
end

[
	{
		:app => "sideview_utils", 
		:cookbook_file => "sideview-utils-lgpl_135.tgz"
	},
	{
		:app => "sos",
		:cookbook_file => "sos-splunk-on-splunk_310.tgz"
	},
	{
		:app => "splunk_app_for_nix",
		:cookbook_file => "splunk-app-for-unix-and-linux_501.tgz"
	},
	{
		:app => "bistro",
		:cookbook_file => "bistro_102.tgz"
	}
].each do |app|
	splunk_app app[:app] do
		action			[:install, :enable]
		app_name		app[:app]
		cookbook_file	app[:cookbook_file]
		splunk_auth 	splunk_auth_info
		enabled			true
		installed		true
		notifies		:restart, 'service[splunk]', :delayed
	end
end

