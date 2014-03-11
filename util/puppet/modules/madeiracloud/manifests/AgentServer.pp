class madeiracloud::webserver{
	
	
	$root = "/root"
	
	$MADEIRA="/madeira"
	$CONF="$MADEIRA/conf"
	$SITE="$MADEIRA/site"
	$LOG="$MADEIRA/log"
	$SOURCE="$MADEIRA/source"
	$DOWNLOAD="$SITE/download/setup"
	$yumpackages = [ "mercurial", "php", "php-xml", "php-mysql", "php-mcrypt", "php-devel", "php-pear", "gmp-devel", "mysql", "nginx", "gcc", "make", "gcc-c++", "uuid-devel", "libuuid-devel", "git","expect" ]
	
	user { "InstantForge": 	   	   
	   ensure => 'present', 	   
	   before => Service["nginx"]
	} 
    File{
        owner=>"InstantForge",
        require=>User["InstantForge"]
    }
    Exec{
        user=>"InstantForge",
        require=>User["InstantForge"]
    }

	package { 
		$yumpackages: 
		ensure => "installed",
		before => [Exec["pear install"],Package["7z"],Exec["MadeiraClone"],Exec["Php-redis"],Exec["zeromq"],Exec["message pack"],Exec["mongodb"]]
		
	}
	package{"7z":
		source => "http://packages.sw.be/p7zip/p7zip-9.20.1-1.el5.rf.x86_64.rpm",
		provider=>"rpm",
		ensure => "installed",		
	}

	exec { "pear install":
	    command => "echo \"isInstall=\\\"`pecl list| grep mongo`\\\";if [ ! -n \\\"\\\$isInstall\\\" ];then echo 'pear channel-discover pear.zero.mq; pecl install mongo; pecl install zero.mq/zmq-beta'| sh;echo \\\"extension=mongo.so\\\">>/etc/php.ini;fi\" | sh",
	    path    => "/usr/local/bin/:/bin/:/usr/bin/",    
	    user=>"root",
	    before => [Exec["mongodb_start"],Service['php-fcgi']]
	}
	

	exec { "Php-redis":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/phpredis ]; then git clone https://github.com/nicolasff/phpredis.git; cd phpredis/; phpize; ./configure; make; make install; cd .. ;echo \\\"extension=redis.so\\\">>/etc/php.ini; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		user=>"root",
		before =>[Exec["mongodb_start"],Service['php-fcgi']]
	}
	
	exec { "zeromq":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/zeromq-2.2.0 ]; then wget http://download.zeromq.org/zeromq-2.2.0.tar.gz; tar xzf zeromq-2.2.0.tar.gz; cd zeromq-2.2.0/; ./configure; make; make install; cd .. ;echo \\\"extension=zmq.so\\\">>/etc/php.ini;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		user=>"root",
		before =>[Exec['pear install'],Service['php-fcgi']],
		timeout => "-1"
	}
	
	exec { "message pack":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/msgpack ]; then git clone https://github.com/msgpack/msgpack.git; cd msgpack/php; phpize; ./configure; make; make install; cd ../.. ;echo \\\"extension=msgpack.so\\\">>/etc/php.ini;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		user=>"root",
		before => Service['php-fcgi']
	}
	
	exec { "mongodb":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $root/mongodb-linux-x86_64-2.0.6 ]; then curl http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.6.tgz > mongo.tgz; tar xzf mongo.tgz; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["mongodb_start"],
		user=>"root",
	}
	
	exec{"mongodb_start":
		cwd=>$root,
		command =>  "echo \"isExists=`pgrep mongo`; if [ -z \\\"\\\$isExists\\\" ]; then configDB=`curl -s --data \\\"method=getMongoConfig\\\" config.madeiracloud:8080/monitorconfig/`; $root/mongodb-linux-x86_64-2.0.6/bin/mongos -configdb \\\$configDB -port 30000 -logpath $MADEIRA/log/mongos.log -logappend -fork;INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;curl -s --data \\\"method=addMongos&instance_id=\\\$INSTANCE_ID&port=30000\\\" config.madeiracloud:8080/monitorconfig/; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		user=>"root",
	
	}
	
	#-------------Directorys--------------#	
	
	file { "$MADEIRA":		
		ensure => "directory",
		before => Exec["MadeiraClone"]
	}
	file { "$LOG":
    	ensure => "directory",
    	before => [Service["nginx"],Exec["mongodb_start"]]
	}
	file { "$SOURCE":
    	ensure => "directory",
    	before => Exec["VulcanClone"]
	}
	file { "$DOWNLOAD":
    	ensure => "directory",
    	before => Exec["VulcanClone"]
	}

	#-------------Version--------------#
	
	file{"/etc/madeiracloud.version":
		#notify  => Exec["Madeira"],
		content => $MEDEIRA_VERSION
	}
	
	#-------------Deploy--------------#
	
	exec { "MadeiraClone":
		cwd=>$root,
		command =>  "echo \"if [ ! -d $MADEIRA/site ]; then echo 'set timeout 1200; spawn hg clone ssh://$HG//opt/source/mainline/Madeira $MADEIRA ;expect \\\"(yes/no)?\\\" {send \\\"yes\\r\\\"; expect \\\"*password:\\\"; send \\\"$password\\\"} \\\"*password:\\\" { send \\\"$password\\\"};expect eof'| expect; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => [File["$LOG"],File["$SOURCE"],File["$DOWNLOAD"],File["/etc/nginx/nginx.conf"],File["/etc/nginx/option.conf"],File["/etc/nginx/proxy.conf"],File["/etc/nginx/com.madeiracloud.www.conf"],File["/etc/nginx/com.madeiracloud.my.conf"],File["/etc/nginx/com.madeiracloud.ide.conf"],File["/etc/nginx/com.madeiracloud.api.conf"],File["/etc/nginx/com.madeiracloud.download.conf"],Exec["MadeiraPull"],Exec["VulcanClone"],Exec["VulcanPull"],Exec["IDEClone"],Exec["IDEPull"],Exec["SauronClone"],Exec["SauronPull"],Exec["start-stop-daemon"],Exec["AWS"],File["$SITE/my/aws/config.inc.php"],File["/etc/init.d/php-fcgi"]],
		timeout => "-1"
	}
	
	exec { "MadeiraPull":
		cwd=>$MADEIRA,
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Madeira;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}	
	
	exec { "VulcanClone":
		cwd=>$SOURCE,
		command =>  "echo \"if [ ! -d $SOURCE/Vulcan/Util ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Vulcan $SOURCE/Vulcan ;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect; cp -rf $SOURCE/Vulcan/Util/script/* $SITE/download/setup/; fi\" | sh",		
	
		path => "/usr/bin:/usr/sbin:/bin",
		timeout => "-1",
		before => Exec["VulcanPull"]

	}
	
	exec { "VulcanPull":
		cwd=>"$SOURCE/Vulcan",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Vulcan;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect; cp -rf $SOURCE/Vulcan/Util/script/* $SITE/download/setup/\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}	
	
	exec { "IDEClone":
		cwd=>"$SITE/ide/",
		command =>  "echo \"if [ ! -d $SITE/ide/src ]; then  echo 'set timeout 600; spawn scp root@211.98.26.6:/data/release/beta/pugna-mainline-1549.7z $SITE/ide/ ;expect \\\"*password:\\\";send \\\"$password\\\";expect eof' | expect; 7za x $SITE/ide/pugna-mainline-1549.7z; rm -f $SITE/ide/pugna-mainline-1549.7z; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		timeout => "-1",
		before => Exec["IDEPull"]
	}
	
	exec { "IDEPull":
		cwd=>"$SITE",
		command =>  "echo \"rm -rf $SITE/ide/; mkdir -p $SITE/ide; echo 'set timeout 600; spawn scp root@211.98.26.6:/data/release/beta/pugna-mainline-1549.7z $SITE/ide/ ;expect \\\"*password:\\\";send \\\"$password\\\";expect eof' | expect; cd $SITE/ide/; 7za x $SITE/ide/pugna.7z; rm -f $SITE/ide/pugna.7z;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}		
		
	exec { "SauronClone":
		cwd=>"$MADEIRA/site/api",
		command =>  "echo \"if [ ! -d $MADEIRA/site/api/monitor ]; then echo 'set timeout 600; spawn hg clone ssh://$HG//opt/source/mainline/Sauron ./Sauron;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect; mkdir -p monitor; ln $SITE/api/Sauron/Source/AgentServer/Frequent_Action.php ${SITE}/api/monitor/index.php;ln $SITE/api/Sauron/Source/AgentServer/Action.php $SITE/api/monitor/Action.php;ln $SITE/api/Sauron/Source/Agent/Agent.sh $SITE/api/monitor/Agent.sh; fi\" | sh",	
		timeout => "-1",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["SauronPull"]	
	}
	
	exec { "SauronPull":
		cwd=>"$MADEIRA/site/api/Sauron",
		command =>  "echo \"echo 'set timeout 600; spawn hg pull ssh://$HG//opt/source/mainline/Sauron;expect \\\"*password:\\\";send \\\"$password\\\";expect eof'| expect;hg update;\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		subscribe => File["/etc/madeiracloud.version"],
		refreshonly => true,
		timeout => "-1"
	}		
	
	exec { "AWS":
		cwd=>"$MADEIRA/site/my",
		command =>  "echo \"if [ ! -d $MADEIRA/site/my/aws ]; then git clone git://github.com/amazonwebservices/aws-sdk-for-php.git $SITE/my/aws; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => File["$SITE/my/aws/config.inc.php"]
	}
	
	file{"/etc/nginx/nginx.conf":
		ensure => "$CONF/nginx/madeira.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/option.conf":
		ensure => "$CONF/nginx/option.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/proxy.conf":
		ensure => "$CONF/nginx/proxy.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/com.madeiracloud.www.conf":
		ensure => "$CONF/nginx/com.madeiracloud.www.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/com.madeiracloud.my.conf":
		ensure => "$CONF/nginx/com.madeiracloud.my.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/com.madeiracloud.ide.conf":
		ensure => "$CONF/nginx/com.madeiracloud.ide.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/com.madeiracloud.download.conf":
		ensure => "$CONF/nginx/com.madeiracloud.download.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"/etc/nginx/com.madeiracloud.api.conf":
		ensure => "$CONF/nginx/com.madeiracloud.api.conf",
		owner=>"root",
		before => Service["nginx"]
	}
	
	file{"$SITE/my/aws/config.inc.php":
		ensure => "$CONF/aws-config.inc.php"
	}
	
	file{"/etc/init.d/php-fcgi":
		ensure => "$MADEIRA/init.d/php-fcgi",
		owner=>"root",
		before => Service["php-fcgi"]		
	}
	
	
	service{ "nginx":
	     ensure => running,
	     subscribe => File["/etc/nginx/nginx.conf","/etc/nginx/option.conf","/etc/nginx/proxy.conf","/etc/nginx/com.madeiracloud.www.conf","/etc/nginx/com.madeiracloud.my.conf","/etc/nginx/com.madeiracloud.ide.conf","/etc/nginx/com.madeiracloud.download.conf","/etc/nginx/com.madeiracloud.api.conf"],
	     before => Exec["mongodb_start"]
	}	

	exec{"start-stop-daemon":
		user=>"root",
		cwd=>"$MADEIRA",
		command =>  "gcc $MADEIRA/init.d/start-stop-daemon.c -o /usr/sbin/start-stop-daemon",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Service["php-fcgi"]		
	}
	service{ "php-fcgi":
		ensure => running,
		subscribe => File["/etc/nginx/nginx.conf","/etc/nginx/option.conf","/etc/nginx/proxy.conf","/etc/nginx/com.madeiracloud.www.conf","/etc/nginx/com.madeiracloud.my.conf","/etc/nginx/com.madeiracloud.ide.conf","/etc/nginx/com.madeiracloud.download.conf","/etc/nginx/com.madeiracloud.api.conf"],	
	}
	
}