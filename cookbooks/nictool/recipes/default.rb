#
# Cookbook Name:: nictool
# Recipe:: default
#
# Copyright 2014, Matt Harris
#

include_recipe "cpan"

%W[ apache2 apache2-threaded-dev libapache2-mod-perl2 libdbd-mysql-perl].each do |pkg|
	apt_package pkg do
		action	:install
	end
end

execute "enable_perl_mod" do
	action	:run
	command "a2enmod perl"
	creates "/etc/apache2/mods-enabled/perl.load"
end

%W[ LWP RPC::XML SOAP::Lite DBI Apache2::DBI Apache2::SOAP Digest::HMAC_SHA1 ].each do |pkg|
	cpan_client pkg do
        user 'root'
        group 'root'
        install_type 'cpan_module'
        action 'install'
    end
end

cookbook_file "NicTool-2.21.tar.gz" do
	path "/tmp/NicTool-2.21.tar.gz"
	action :create_if_missing
end

execute "expand_nictool_tarball" do
	command	"tar -zxvf /tmp/NicTool-2.21.tar.gz"
	cwd		"/tmp"
	creates "/tmp/server/NicToolServer-2.21.tar.gz"
end

execute "expand_nictool_server_tarball" do
	command	"tar -zxvf /tmp/server/NicToolServer-2.21.tar.gz"
	cwd		"/tmp/server"
	creates "/tmp/server/NicToolServer-2.21/Makefile.PL"
	notifies :run, "execute[build_nictool]"
end

directory "/usr/local/nictool/server" do
	action		:create
	recursive	true
end

execute "build_nictool" do
	action	:nothing
	cwd		"/tmp/server/NicToolServer-2.21"
	command	"perl Makefile.PL && make install clean"
end

execute "move_nictool_to_documentroot" do
	command 	"cp -avr /tmp/server/NicToolServer-2.21/* /usr/local/nictool/server/"
	creates 	"/var/local/nictool/server/Makefile.PL"	
	cwd 		"/tmp/server"
end

template "#{node['apache']['dir']}/sites-available/nictool.conf" do
	source	"mods/nictool.conf.erb"
	action	:create
end

apache_site "nictool" do
	action	:enable
end