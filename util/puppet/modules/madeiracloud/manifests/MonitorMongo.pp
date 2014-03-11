class madeiracloud::monitormongo{
	$MADEIRACLOUD="/usr/local/madeiracloud"
	$root="/root"
	package{"xfsprogs":
		ensure => "installed",	
		before => Exec["mount"]
	}
	file{"/etc/madeiracloud.version":
		#notify  => Exec["Madeira"],
		content => $MEDEIRA_VERSION
	}
	file{"$MADEIRACLOUD":
		ensure => "directory",
		before => [Exec["mount"],Exec["mongodb"]]
	}
	exec{ "mount":
		cwd=>"/root",
		command =>  "echo \"if [ ! -b /dev/md0 ]; then yes | mdadm -C /dev/md0 --chunk=256 -n 8 -l 0 /dev/sda4 /dev/sda5 /dev/sda6 /dev/sda7 /dev/sda8 /dev/sda9 /dev/sda10 /dev/sda11;blockdev --setra 65536 /dev/md0;mkfs.xfs /dev/md0;mount /dev/md0 $MADEIRACLOUD;fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin:/sbin",
		before => Exec['mongodb']
	}

	exec { "mongodb":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"if [ ! -d $MADEIRACLOUD/mongodb-linux-x86_64-2.0.6 ]; then curl http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.6.tgz > mongo.tgz; tar xzf mongo.tgz; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		before => Exec["mongodb_start"]
	}
	
	exec{"mongodb_start":
		cwd=>$MADEIRACLOUD,
		command =>  "echo \"isExists=`pgrep mongo`; if [ -z \\\"\\\$isExists\\\" ]; then INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`;MongoConfig=\`curl -s --data \\\"method=addMongo&instance_id=\\\$INSTANCE_ID&port=27017\\\" config.madeiracloud:8080/monitorconfig/\`;IFS=\\\"|\\\";set -- \\\$MongoConfig;mkdir -p $MADEIRACLOUD/db;mkdir -p $MADEIRACLOUD/db/\\\$1; $MADEIRACLOUD/mongodb-linux-x86_64-2.0.6/bin/mongod -shardsvr -replSet \\\$1 -port 27017 -dbpath $MADEIRACLOUD/db/\\\$1 -oplogSize 5000 -logpath $MADEIRACLOUD/db/\\\$1.log -fork;if [ \\\"\\\$2\\\" = \\\"1\\\" ];then sleep 4m; curl -s --data \\\"method=addReplicaSet&setname=\\\$1\\\" config.madeiracloud:8080/monitorconfig/;fi; fi\" | sh",
		path => "/usr/bin:/usr/sbin:/bin",
		timeout => "-1",
	}
	
}