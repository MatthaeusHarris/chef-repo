#
# Cookbook Name:: uberdefault
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe "users::default"

users_manage "admin" do
	group_id	2301
	action		[ :remove, :create ]
end

