#
# Cookbook Name:: ubermail
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

%W(postfix fam courier-pop-ssl courier-imap-ssl 
	courier-ssl courier-pop courier-imap courier-base
	libsasl2-2 libsasl2-modules libsasl2-modules-sql 
	openssl).each do |package|
	apt_package package do 
		action		:install
	end
end

directory "/mail" do
	owner		"postfix"
	group		"postfix"
	mode 		"0755"
	action	:create
end