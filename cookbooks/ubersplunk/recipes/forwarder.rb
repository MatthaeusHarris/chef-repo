#
# Cookbook Name:: ubersplunk
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

cookbook_file "/tmp/splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb" do
	backup		false
	source		"splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb"
end

dpkg_package "splunkforwarder" do
	action 		:install
	source		"/tmp/splunkforwarder-6.0.1-189883-linux-2.6-amd64.deb"
end

service 'splunk' do
  action [:enable]
  supports :status => true, :start => true, :stop => true, :restart => true
end

splunk_bin = node[:splunkforwarder][:bin]

execute "#{splunk_bin} start" do
	not_if "/etc/init.d/splunk status"
end

execute "#{splunk_bin} enable boot-start --accept-license --answer-yes" do
	not_if{ File.symlink?("/etc/rc4.d/S20splunk") }
end

execute "#{splunk_bin} edit user #{node[:splunkforwarder][:admin][:username]} -password #{node[:splunkforwarder][:admin][:password]} -roles admin" do
	only_if "#{splunk_bin} login -auth admin:changeme"
end

execute "#{splunk_bin} login -auth #{node[:splunkforwarder][:admin][:username]}:#{node[:splunkforwarder][:admin][:password]}"


execute "#{splunk_bin} add forward-server #{node[:splunkforwarder][:forward_server]}" do
	not_if "#{splunk_bin} list forward-servers | grep #{node[:splunkforwarder][:forward_server]}"
end

node[:splunkforwarder][:inputs].each do |key, value|
	command = "#{splunk_bin} add monitor #{value[:file]}"
	command << " -index #{value[:index]}" if value[:index]
	command << " -sourcetype #{value[:sourcetype]}" if value[:sourcetype]
	execute command do
		not_if "#{splunk_bin} list monitor | grep #{value[:file]}"
	end
end