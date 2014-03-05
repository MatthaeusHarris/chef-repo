#
# Cookbook Name:: ubersplunk
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe 'chef-vault'

splunk_auth_info = chef_vault_item(:vault, "splunk_#{node.chef_environment}")['auth']

splunk_app "sideview_utils" do
	action			[:install, :enable]
	app_name		"sideview_utils"
	cookbook_file	"sideview-utils-lgpl_135.tgz"
	splunk_auth 	splunk_auth_info
	enabled			true
	installed		true
end

splunk_app "sos" do
	action			[:install, :enable]
	app_name		"sos"
	cookbook_file	"sos-splunk-on-splunk_310.tgz"
	splunk_auth 	splunk_auth_info
	enabled			true
	installed		true
	notifies		:restart, 'service[splunk]', :delayed
end

splunk_app "splunk_app_for_nix" do
	action			[:install, :enable]
	cookbook_file	"splunk-app-for-unix-and-linux_501.tgz"
	splunk_auth 	splunk_auth_info
	enabled			true
	installed		true
	notifies		:restart, 'service[splunk]', :delayed
end

