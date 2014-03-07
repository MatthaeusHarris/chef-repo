#
# Cookbook Name:: ubermail
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

apt_package "postfix" do 
	action		:install
end