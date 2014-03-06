#
# Cookbook Name:: ubersplunk_handler
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

splunk_auth_info = chef_vault_item(:vault, "splunk_#{node.chef_environment}")['auth']
(splunk_username, splunk_password) = splunk_auth_info.split(':')

splunk_servers = search(
  :node,
  "splunk_is_server:true AND chef_environment:#{node.chef_environment}"
).sort! do
  |a, b| a.name <=> b.name
end

splunk_host = splunk_servers[0]['ipaddress']

if splunk_host
	include_recipe "chef_handler"
	
	chef_gem 'chef-handler-splunk' do
		version '2.1.0'
	end

	chef_handler 'Chef::Handler::SplunkHandler' do
		action	:enable
		arguments [
			username=splunk_username,
			password=splunk_password,
			host=splunk_host,
			port=8089,
			index="main",
			scheme="https"
		]
		source File.join(Gem.all_load_paths.grep(/chef-handler-splunk/).first,
                     'chef', 'handler', 'splunk.rb')
	end
end