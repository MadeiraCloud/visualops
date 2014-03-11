class madeiracloud::redis{
	
	$MEDEIRA_VERSION="0.0.1"
	$root = "/root"
	$HG="root@211.98.26.6"
	$MADEIRA="/madeira"	
	$yumpackages = [ "mercurial", "libtool","autoconf", "automake", "make", "libuuid-devel", "gcc", "gcc-c++","expect" ]
	$MADEIRACLOUD="/usr/local/madeiracloud"

	package { 
		$yumpackages: 
		ensure => "installed",
		before => [File["$MADEIRACLOUD"],Mount["$MADEIRACLOUD"],Exec["SauronClone"],Exec["SauronPull"]]
		
	}
	file{"/etc/madeiracloud.version":
		#notify  => Exec["Madeira"],
		content => $MEDEIRA_VERSION
	}
	
	
	mount {"$MADEIRACLOUD":
		device => "/dev/xvda2",		
		before =>[Exec["redis_install"],Exec["SauronClone"]]
	}
	
	file{"$MADEIRACLOUD":
		ensure => "directory",
		before => [Mount["$MADEIRACLOUD"],Exec["redis_install"],Exec["SauronClone"]]
	}
	
	exec{"redis_install":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/redis-2.4.14 ]; then wget http://redis.googlecode.com/files/redis-2.4.14.tar.gz;tar xzf redis-2.4.14.tar.gz ;cd redis-2.4.14; make; make install; cd .. ;echo \\\"extension=redis.so\\\">>/etc/php.ini; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["redis_start"]
	
	}
	file{"$MADEIRACLOUD/redis.conf":
		ensure => "$root/Sauron/Util/conf/redis.conf",
		before => Exec["redis_start"]
	}
	exec { "SauronClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d $root/Sauron ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron $root/Sauron;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"InstantCloud123\\!\\@\\#\\r\\\"} \\\"*password:\\\" { send \\\"InstantCloud123\\!\\@\\#\\r\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>File["$MADEIRACLOUD/redis.conf"]
	}
	
	exec { "SauronPull":
		cwd=>"$root/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"InstantCloud123\\!\\@\\#\\r\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}
	
	exec{"redis_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=`pgrep redis`; if [ \\\"\\\$isExists\\\"==\\\"\\\" ]; then redis-server $MADEIRACLOUD/redis.conf;INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addRedis&instance_id=\\\$INSTANCE_ID&port=6379\\\" https://api.madeiracloud.com/monitorconfig/; fi\" | sh",
		path => "/usr/bin:/usr/local/bin:/bin",		
	}
}