
$HG="root@211.98.26.6"
$password="InstantCloud123\\!\\@\\#\\r"
$MEDEIRA_VERSION="0.0.1"

node /^\S*\.redis\.monitor\.madeiracloud$/{
	
	include madeiracloud::monitorredis
}

node /^\S*\.mongo\.monitor\.madeiracloud$/{	
	
	include madeiracloud::monitormongo
}

node /^\S*\.monitorserver\.monitor\.madeiracloud$/{
	
	include madeiracloud::monitorserver
}

node /^\S*\.config\.monitor\.madeiracloud$/{
	
	include madeiracloud::monitorconfig
}

node /^\S*\.webserver\.madeiracloud$/{
	
	include madeiracloud::webserver
}
