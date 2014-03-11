class MadeiraCloud::MonitorConfigInstall{
	
	$MEDEIRA_VERSION="0.0.1"
	$root = "/root"
	$HG="root@211.98.26.6"
	$MADEIRA="/madeira"	
	$yumpackages = [ "mercurial", "php","php-fpm", "php-devel", "php-pear", "nginx", "gcc", "make", "git","expect" ]
	$MADEIRACLOUD="/usr/local/madeiracloud"
	
	package { 
		$yumpackages: 
		ensure => "installed",
		before => [Exec["pear install"],Exec["Php-redis"],Exec["SauronClone"],Exec["SauronPull"]]
		
	}
	file{"/etc/madeiracloud.version":
		#notify  => Exec["Madeira"],
		content => $MEDEIRA_VERSION
	}
	service{ "nginx":
	     ensure => running,
	     subscribe => File[""]
	     before => Exec["mongodb_start"]
	}	
	
	service{ "php-fpm":
		ensure => running,	
	}
	
	file{"/etc/nginx/nginx.conf":
		ensure => "$root/Sauron/Source/conf/nginx.conf",
		owner=>"root",
		before => Service["nginx"]
	}	
	
	file{"$MADEIRACLOUD":
		ensure => "directory",
		before => [Exec["mongodb"],File["$MADEIRACLOUD/db"]]
	}
	
	file{"$MADEIRACLOUD/db":
		ensure => "directory",
		before => Exec["mongodb_start"]
	}
	
	file{"/usr/share/nginx/html/monitorconfig/index.php":
		ensure => "$root/Sauron/Source/MadeiraSite/index.php",	
	}
	
	exec { "pear install":
	    command => "echo \"isInstall=`pecl list| grep mongo`;if [[ \\\$isInstall != *mongo* ]];then echo 'pear channel-discover pear.zero.mq; pecl install mongo'| sh;echo \\\"extension=mongo.so\\\">>/etc/php.ini;fi\" | sh",
	    path    => "/usr/local/bin/:/bin/:/usr/bin/",    
	}
	
	exec { "Php-redis":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/phpredis ]; then git clone https://github.com/nicolasff/phpredis.git; cd phpredis/; phpize; ./configure; make; make install; cd .. ;echo \\\"extension=redis.so\\\">>/etc/php.ini; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin"
	}
	
	exec { "SauronClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d /usr/share/nginx/html/monitorconfig ]; then mkdir -p /usr/share/nginx/html/monitorconfig;echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron $root/Sauron;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"InstantCloud123\\!\\@\\#\\r\\\"} \\\"*password:\\\" { send \\\"InstantCloud123\\!\\@\\#\\r\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1",
		path => "/usr/bin:/usr/sbin:/bin",
		before =>[Service["nginx"],File["/etc/nginx/nginx.conf"],File["/usr/share/nginx/html/monitorconfig/index.php"]]
	}
	
	exec { "SauronPull":
		cwd=>"$root/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"InstantCloud123\\!\\@\\#\\r\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}
	
	exec { "mongodb":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/mongodb-linux-x86_64-2.0.5 ]; then curl http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.5.tgz > mongo.tgz; tar xzf mongo.tgz; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["mongodb_start"]
	}
	
	exec{"mongodb_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=`pgrep mongo`; if [ \\\"\\\$isExists\\\"==\\\"\\\" ]; then $MADEIRACLOUD/mongodb-linux-x86_64-2.0.5/bin/mongod -configsvr -dbpath $MADEIRACLOUD/db -port 20000 -logpath $MADEIRACLOUD/db/config.log -fork;IP=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`;INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addMongoConfig&instance_id=\\\$INSTANCE_ID&port=20000\\\" $IP; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",		
	}
	
	
}