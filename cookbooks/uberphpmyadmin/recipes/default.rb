#
# Cookbook Name:: uberphpmyadmin
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe 'apache2::default'
include_recipe 'apache2::mod_php5'
include_recipe 'database::mysql'
include_recipe 'mysql::server'

packages = %w(php5-mysql phpmyadmin)

packages.each do |pkg|
	package pkg do 
		action		:install
	end
end

link "/etc/apache2/conf.d/phpmyadmin.conf" do
	to		"/etc/phpmyadmin/apache.conf"
	notifies	:reload, "service[apache2]"
end