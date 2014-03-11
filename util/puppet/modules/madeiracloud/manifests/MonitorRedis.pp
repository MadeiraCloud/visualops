class madeiracloud::monitorredis{
	
	$root = "/root"
	
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
        before =>[Exec["redis_install"],Exec["SauronClone"]],
        ensure  => mounted,
        atboot  => true,
        fstype  => "ext3",

	}
	
	file{"$MADEIRACLOUD":
		ensure => "directory",
		before => [Mount["$MADEIRACLOUD"],Exec["redis_install"],Exec["SauronClone"]]
	}
	
	exec{"redis_install":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/redis-2.4.15 ]; then wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz;tar xzf redis-2.4.15.tar.gz ;cd redis-2.4.15; make; make install; cd .. ;echo \\\"extension=redis.so\\\">>/etc/php.ini; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["redis_start"]
	
	}
	file{"$MADEIRACLOUD/redis.conf":
		ensure => "$root/Sauron/Util/conf/redis.conf",
		before => Exec["redis_start"]
	}
	exec { "SauronClone":
		cwd=>"$root",
		command =>  "echo \"if [ ! -d $root/Sauron ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron $root/Sauron;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"$password\\\"} \\\"*password:\\\" { send \\\"$password\\\"};expect eof'| expect; fi\" | sh",	
		timeout => "-1", 
		path => "/usr/bin:/usr/sbin:/bin",
		before =>[File["$MADEIRACLOUD/redis.conf"],Exec['SauronPull']]
	}
	
	exec { "SauronPull":
		cwd=>"$root/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}
	
	exec{"redis_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=`pgrep redis`; if [ -z \\\"\\\$isExists\\\" ]; then redis-server $MADEIRACLOUD/redis.conf;INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addRedis&instance_id=\\\$INSTANCE_ID&port=6379\\\" config.madeiracloud:8080/monitorconfig/; fi\" | sh",
		path => "/usr/bin:/usr/local/bin:/bin",		
	}
}