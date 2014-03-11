class madeiracloud::monitorserver{

	$root = "/root"	
	$MADEIRA="/madeira"	
	$yumpackages = [ "mercurial", "libtool","autoconf", "automake", "make", "libuuid-devel", "python-setuptools", "gcc-c++","expect","python-devel","git" ]
	$MADEIRACLOUD="/usr/local/madeiracloud"

	package { 
		$yumpackages: 
		ensure => "installed",	
		before=>[Exec['zeromq'],Exec['scribe'],Exec['SauronClone']]
		
	}	
	file{"/etc/madeiracloud.version":
		#notify  => Exec["Madeira"],
		content => $MEDEIRA_VERSION
	}	
	file{"$MADEIRACLOUD":
		ensure => "directory",	
		before =>[Exec["mongodb_start"],Exec["SauronClone"]]
	}
	
	exec{"py_package":
		cwd=>$root,
		command =>  "echo \"easy_install pip;easy_install thrift;easy_install msgpack-python;easy_install boto;easy_install tornado;easy_install redis;easy_install pymongo;easy_install pyzmq\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => [Exec["mongodb_start"],Exec['monitor_start']]
	}	
	
	exec { "scribe":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/scribe ]; then git clone git://github.com/facebook/scribe.git; cd scribe/lib/py/; python setup.py install; cd ../.. ;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"
	}
			
	exec { "zeromq":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/zeromq-2.2.0 ]; then wget http://download.zeromq.org/zeromq-2.2.0.tar.gz; tar xzf zeromq-2.2.0.tar.gz; cd zeromq-2.2.0/; ./configure; make; make install;ldconfig; cd .. ;echo \\\"extension=zmq.so\\\">>/etc/php.ini;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec['py_package'],
		timeout => "-1", 
	}
	
	exec { "mongodb":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/mongodb-linux-x86_64-2.0.6 ]; then curl http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.6.tgz > mongo.tgz; tar xzf mongo.tgz; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["mongodb_start"]
	}
	
	exec{"mongodb_start":
		cwd=>$root,
		command =>  "echo \"isExists=\\\"`pgrep mongo`\\\"; if [ -z \\\"\\\$isExists\\\" ]; then configDB=\\\"`curl -s --data \\\"method=getMongoConfig\\\" config.madeiracloud:8080/monitorconfig/`\\\"; $root/mongodb-linux-x86_64-2.0.6/bin/mongos -configdb \\\$configDB -port 30000 -logpath $MADEIRACLOUD/mongos.log -logappend -fork; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"	
	}
	
	exec { "SauronClone":
		cwd=>"$MADEIRACLOUD",
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/Sauron ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron $MADEIRACLOUD/Sauron;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"$password\\\"} \\\"*password:\\\" { send \\\"$password\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>[File["$MADEIRACLOUD/monitor.py"],File["$MADEIRACLOUD/Constant.py"],Exec["ValkyrieClone"],Exec['SauronPull'],File['/usr/lib/python2.6/site-packages/fb303.zip'],File['/usr/lib/python2.6/site-packages/fb303.zip.pth']]
	}
	
	exec { "SauronPull":
		cwd=>"$MADEIRACLOUD/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect;hg update;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1",
		before => File["$MADEIRACLOUD/Troll/Source/INiT/Instant/Runtime"]
	}	
	
	exec { "TrollClone":
		cwd=>"$MADEIRACLOUD",
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/Troll ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Troll $MADEIRACLOUD/Troll;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"$password\\\"} \\\"*password:\\\" { send \\\"$password\\\"};expect eof'| expect;export PYTHONPATH=$MADEIRACLOUD/Troll/Source/; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",		
		before =>[Exec["monitor_start"],Exec['TrollPull'],File["$MADEIRACLOUD/Troll/Source/INiT/Instant/Runtime"]]
	}
	
	exec { "TrollPull":
		cwd=>"$MADEIRACLOUD/Troll",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Troll;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect;rm -f $MADEIRACLOUD/Troll/Source/INiT/Instant/Runtime; hg update;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1",
		before=>File["$MADEIRACLOUD/Troll/Source/INiT/Instant/Runtime"]		
	}
	
	file{"$MADEIRACLOUD/Troll/Source/INiT/Instant/Runtime":
		ensure=>"$MADEIRACLOUD/Valkyrie/Source/INiT/Instant/Runtime",			
		before=>Exec["monitor_start"]	
	}
	
	exec { "ValkyrieClone":
		cwd=>"$MADEIRACLOUD",
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/Valkyrie ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Valkyrie $MADEIRACLOUD/Valkyrie;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"$password\\\"} \\\"*password:\\\" { send \\\"$password\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>[Exec["TrollClone"],Exec['ValkyriePull']]
	}
	
	exec { "ValkyriePull":
		cwd=>"$MADEIRACLOUD/Valkyrie",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Valkyrie;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect;hg update;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}
	
	file{"/usr/lib/python2.6/site-packages/fb303.zip":
		source => "$MADEIRACLOUD/Sauron/Util/conf/fb303.zip",
		before => Exec["monitor_start"]
	}
	
	file{"/usr/lib/python2.6/site-packages/fb303.zip.pth":
		source => "$MADEIRACLOUD/Sauron/Util/conf/fb303.zip.pth",
		before => Exec["monitor_start"]
	}
	
	file{"$MADEIRACLOUD/monitor.py":
		source => "$MADEIRACLOUD/Sauron/Source/Monitor/Monitor_v1.py",
		before => Exec["monitor_start"]
	}
	
	file{"$MADEIRACLOUD/Constant.py":
		source => "$MADEIRACLOUD/Sauron/Source/Monitor/Constant.py",
		before => Exec["monitor_start"]
	}
	
	exec{"monitor_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=\\\"`pgrep python`\\\";if [ -z \\\"\\\$isExists\\\" ]; then INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addMonitorServer&instance_id=\\\$INSTANCE_ID&port=5558\\\" config.madeiracloud:8080/monitorconfig/;curl -s --data \\\"method=addMongos&instance_id=\\\$INSTANCE_ID&port=30000\\\" config.madeiracloud:8080/monitorconfig/;export PYTHONPATH=$MADEIRACLOUD/Troll/Source/;python $MADEIRACLOUD/monitor.py start; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",	
		before => Exec['monitor_restart']	
	}
	exec{"monitor_restart":
		cwd=>$MADEIRACLOUD,
		command => "echo \"export PYTHONPATH=$MADEIRACLOUD/Troll/Source/;python monitor.py restart\" | sh",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		path => "/usr/bin:/usr/sbin:/bin",
	}
	
}