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

execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
  	!File.exists?('/var/lib/apt/peridic/update-success-stamp') || 
    (File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400)
  end
end

%W(language-pack-en language-pack-en-base).each do |pkg|
	apt_package pkg do
		action		:install
	end
end