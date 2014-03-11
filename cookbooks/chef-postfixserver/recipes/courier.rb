daemons = %w(courier-authdaemon courier-imap 
courier-imap-ssl courier-pop 
courier-pop-ssl)

%w(courier-base courier-imap courier-authdaemon 
courier-authlib courier-authlib-mysql 
courier-imap-ssl courier-pop courier-pop-ssl
courier-ssl libsasl2-2 libsasl2-modules 
libsasl2-modules-sql).each do |pkg|
	apt_package pkg do
		action	:install
	end
end

%w(authdaemonrc authmysqlrc).each do |file|
	template File.join('', 'etc', 'courier', file) do
		source		"courier/#{file}.erb"
		owner		"root"
		group		"root"
		mode 		"0660"
		daemons.each do |daemon|
			notifies	:restart, "service[#{daemon}]", :delayed
		end
	end
end	

daemons.each do |daemon|
	service daemon do
		action		:enable
		supports	[:enable, :restart]
	end
end