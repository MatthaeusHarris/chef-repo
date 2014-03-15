#
# Cookbook Name:: rhodecode
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe 'database::mysql'


# Create user

user node['rhodecode']['user'] do
	comment		"RhodeCode service account"
	supports 	:manage_home => true
	uid				node['rhodecode']['uid']
	home 			node['rhodecode']['homedir']
	shell			"/bin/false"
	password	"!"
end

directory "#{node['rhodecode']['homedir']}/rhodecode" do
	user 			node['rhodecode']['user']
	action		:create
end

# Download installer to user's home dir

remote_file "#{node['rhodecode']['homedir']}/rhodecode/rhodecode-installer.py" do
	source		node['rhodecode']['url']
	checksum	node['rhodecode']['checksum']
	mode			0755
end

# Set up database

database_node = search(:node, "fqdn:#{node['rhodecode']['database']['host']}")[0]
mysql_connection_info = {
  :host     => database_node['fqdn'],
  :username => 'root',
  :password => database_node['mysql']['server_root_password']
}

node.set_unless['rhodecode']['database']['password'] = secure_password

mysql_database node['rhodecode']['database']['database'] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node['rhodecode']['database']['user'] do
  connection 			mysql_connection_info
  password   			node['rhodecode']['database']['password']
  database_name		node['rhodecode']['database']['database']
  host						node['fqdn']
  action     			:grant
end

# Set up unattended install file

template "#{node['rhodecode']['homedir']}/rhodecode/noninteractive.ini" do
	source	"noninteractive.ini.erb"
	owner		node['rhodecode']['user']
	mode		0644
end

# Run unattended install

execute "rhodecode-installer" do
	command		"python rhodecode-installer.py -n"
	cwd				"#{node['rhodecode']['homedir']}/rhodecode/"
	creates		"#{node['rhodecode']['homedir']}/rhodecode/system/bin/rhodecode"
end

service "rhodecode" do
	action	:enable
end