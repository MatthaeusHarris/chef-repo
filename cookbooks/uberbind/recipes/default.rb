#
# Cookbook Name:: uberbind
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

apt_package "bind9" do 
	action	:install
end