class MadeiraCloud::MonitorServerInstall{

	$MEDEIRA_VERSION="0.0.1"
	$root = "/root"
	$HG="root@211.98.26.6"
	$MADEIRA="/madeira"	
	$yumpackages = [ "mercurial", "libtool","autoconf", "automake", "make", "libuuid-devel", "python-setuptools", "gcc-c++","expect","python-devel","git" ]
	$MADEIRACLOUD="/usr/local/madeiracloud"

	package { 
		$yumpackages: 
		ensure => "installed",	
		
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
		command =>  "echo \"easy_install pip;easy_install thrift;easy_install fb303;easy_install msgpack-python;easy_install redis;easy_install pymongo;easy_install pyzmq\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["redis_start"]	
	}	
	
	exec { "scribe":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/scribe ]; then git clone git://github.com/facebook/scribe.git; cd scribe/lib/py/; python setup.py install; cd ../.. ;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"
	}
			
	exec { "zeromq":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/zeromq-2.2.0 ]; then wget http://download.zeromq.org/zeromq-2.2.0.tar.gz; tar xzf zeromq-2.2.0.tar.gz; cd zeromq-2.2.0/; ./configure; make; make install;ldconfig; cd .. ;echo \\\"extension=zmq.so\\\">>/etc/php.ini;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"
	}
	
	exec { "mongodb":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/mongodb-linux-x86_64-2.0.5 ]; then curl http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.5.tgz > mongo.tgz; tar xzf mongo.tgz; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["mongodb_start"]
	}
	
	exec{"mongodb_start":
		cwd=>$root,
		command =>  "echo \"isExists=`pgrep mongo`; if [ \\\"\\\$isExists\\\"==\\\"\\\" ]; then configDB=\\\"`curl -s --data \\\"method=getMongoConfig\\\" https://api.madeiracloud.com/monitorconfig/`\\\"; $root/mongodb-linux-x86_64-2.0.5/bin/mongos -configdb \\\$configDB -port 30000 -logpath $MADEIRACLOUD/mongos.log -logappend -fork; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"	
	}
	
	exec { "SauronClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d $root/Sauron ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron $root/Sauron;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"InstantCloud123\\!\\@\\#\\r\\\"} \\\"*password:\\\" { send \\\"InstantCloud123\\!\\@\\#\\r\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>[File["$MADEIRACLOUD/monitor.py"],File["$MADEIRACLOUD/Constant.py"],Exec["ValkyrieClone"]]
	}
	
	exec { "SauronPull":
		cwd=>"$root/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"InstantCloud123\\!\\@\\#\\r\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}	
	
	exec { "TrollClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d $root/Troll ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Troll $root/Troll;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"InstantCloud123\\!\\@\\#\\r\\\"} \\\"*password:\\\" { send \\\"InstantCloud123\\!\\@\\#\\r\\\"};expect eof'| expect;ln -s $root/Valkyrie/Source/INiT/Instant/Runtime $root/Troll/Source/INiT/Instant/Runtime;export PYTHONPATH=$root/Troll/Source/; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",		
		before =>Exec["monitor_start"]
	}
	
	exec { "TrollPull":
		cwd=>"$root/Troll",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Troll;expect \\\"*password:\\\";send \\\"InstantCloud123\\!\\@\\#\\r\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1",
		
	}
	
	exec { "ValkyrieClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d $root/Valkyrie ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Valkyrie $root/Valkyrie;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"InstantCloud123\\!\\@\\#\\r\\\"} \\\"*password:\\\" { send \\\"InstantCloud123\\!\\@\\#\\r\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>Exec["TrollClone"]
	}
	
	exec { "ValkyriePull":
		cwd=>"$root/Valkyrie",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Valkyrie;expect \\\"*password:\\\";send \\\"InstantCloud123\\!\\@\\#\\r\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}
	
	file{"$MADEIRACLOUD/monitor.py":
		ensure => "$root/Sauron/Source/Monitor/Monitor_v1.py",
		before => Exec["monitor_start"]
	}
	
	file{"$MADEIRACLOUD/Constant.py":
		ensure => "$root/Sauron/Source/Monitor/Constant.py",
		before => Exec["monitor_start"]
	}
	
	exec{"monitor_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=`pgrep monitor`; if [ \\\"\\\$isExists\\\"==\\\"\\\" ]; then python $MADEIRACLOUD/monitor.py&;INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addMonitorServer&instance_id=\\\$INSTANCE_ID&port=5558\\\" https://api.madeiracloud.com/monitorconfig/;curl -s --data \\\"method=addMongos&instance_id=\\\$INSTANCE_ID&port=30000\\\" https://api.madeiracloud.com/monitorconfig/ fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",		
	}
	
	
}