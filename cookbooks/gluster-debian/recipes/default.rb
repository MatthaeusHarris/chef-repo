#
# Cookbook Name:: gluster-debian
# Recipe:: default
#
# Copyright 2014, Matt Harris
#


apt_repository "gluster-debian" do 
	uri "http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.2/Debian/apt"
	distribution node['lsb']['codename']
	components ["main"]
	key "http://download.gluster.org/pub/gluster/glusterfs/3.4/3.4.2/Debian/pubkey.gpg"
	action :add
	notifies :run, "execute[apt-get update]", :immediately
end

package "glusterfs-client"
package "glusterfs-server"

service "glusterfs-server" do
	action [:enable, :start]
end