
#### Installing and configuring Apache2 ####
APACHE_NAME="apache2"
mkdir -p /etc/$APACHE_NAME/ssl
if [[ ! -f /etc/$APACHE_NAME/ssl/apache.key || ! -f /etc/$APACHE_NAME/ssl/apache.crt ]]; then
  echo "Creating self signed SSL certificate for $YOUR_SKYLINE_SERVER_FQDN"
  sleep 1
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=None/L=None/O=Testing/CN=$YOUR_SKYLINE_SERVER_FQDN" \
    -keyout /etc/$APACHE_NAME/ssl/apache.key -out /etc/$APACHE_NAME/ssl/apache.crt
  if [ $? -ne 0 ]; then
    echo "error :: openssl failed to create self signed SSL certificate for $YOUR_SKYLINE_SERVER_FQDN"
    exit 1
  fi
else
  echo "Skipping creation of self signed SSL certificate for $YOUR_SKYLINE_SERVER_FQDN, already done."
  sleep 1
fi
HTTP_AUTH_FILE="/etc/apache2/.skyline_htpasswd"
if [ ! -f $HTTP_AUTH_FILE ]; then
  echo "Creating http auth file - $HTTP_AUTH_FILE"
  sleep 1
  echo "htpasswd -b -c $HTTP_AUTH_FILE $WEBAPP_AUTH_USER $WEBAPP_AUTH_USER_PASSWORD"
  htpasswd -b -c $HTTP_AUTH_FILE $WEBAPP_AUTH_USER $WEBAPP_AUTH_USER_PASSWORD
  if [ $? -ne 0 ]; then
    echo "error :: htpasswd failed to create $HTTP_AUTH_FILE"
    exit 1
  fi
else
  echo "Creating http auth file - $HTTP_AUTH_FILE"
  sleep 1
fi
SKYLINE_HTTP_CONF_FILE="/etc/apache2/sites-available/skyline.conf"
if [ ! -f $SKYLINE_HTTP_CONF_FILE ]; then
  echo "Creating http config - $SKYLINE_HTTP_CONF_FILE"
  sleep 1
  YOUR_ERROR_LOG="\/var\/log\/${APACHE_NAME}\/skyline.error.log"
  YOUR_CUSTOM_LOG="\/var\/log\/${APACHE_NAME}\/skyline.access.log"
  YOUR_PATH_TO_YOUR_CERTIFICATE_FILE="\/etc\/${APACHE_NAME}\/ssl\/apache.crt"
  YOUR_PATH_TO_YOUR_KEY_FILE="\/etc\/${APACHE_NAME}\/ssl\/apache.key"
  if [ "$OS" == "CentOS" ]; then
    YOUR_HTPASSWD_FILE="\/etc\/${APACHE_NAME}\/conf.d\/.skyline_htpasswd"
  else
    YOUR_HTPASSWD_FILE="\/etc\/${APACHE_NAME}\/.skyline_htpasswd"
  fi

  cat $WORKSPACE_DIR/etc/skyline.httpd.conf.d.example \
    | sed -e 's/<YOUR_SERVER_IP_ADDRESS>/'$YOUR_SERVER_IP_ADDRESS'/g' \
    | sed -e 's/<YOUR_SKYLINE_SERVER_FQDN>/'$YOUR_SKYLINE_SERVER_FQDN'/g' \
    | sed -e 's/<YOUR_EMAIL>/'$YOUR_EMAIL'/g' \
    | sed -e 's/<YOUR_ERROR_LOG>/'$YOUR_ERROR_LOG'/g' \
    | sed -e 's/"<YOUR_CUSTOM_LOG>"/"'$YOUR_CUSTOM_LOG'" combined/g' \
    | sed -e 's/<YOUR_PATH_TO_YOUR_CERTIFICATE_FILE>/'$YOUR_PATH_TO_YOUR_CERTIFICATE_FILE'/g' \
    | sed -e 's/<YOUR_PATH_TO_YOUR_KEY_FILE>/'$YOUR_PATH_TO_YOUR_KEY_FILE'/g' \
    | sed -e 's/SSLCertificateChainFile/#SSLCertificateChainFile/g' \
    | sed -e 's/<YOUR_HTPASSWD_FILE>/'$YOUR_HTPASSWD_FILE'/g' \
    | sed -e 's/<YOUR_OTHER_IP_ADDRESS>/'$YOUR_OTHER_IP_ADDRESS'/g' > $SKYLINE_HTTP_CONF_FILE
else
  echo "Skipping creating http config - $SKYLINE_HTTP_CONF_FILE, already done."
fi
a2enmod ssl
a2enmod proxy
a2enmod proxy_http
a2enmod headers
a2enmod rewrite
sed -i 's/.*IfModule.*//g;s/.*LoadModule.*//g' /etc/apache2/sites-available/skyline.conf
a2ensite skyline.conf
#### END ####


#### Configuring Memcache ####
sed -i 's/-m 64/#-m 64\n-m 256/g' /etc/memcached.conf
### END ###


#### Skyline settings ####
if [ ! -f $WORKSPACE_DIR/skyline/settings.py.original ]; then
  echo "Populating variables in the Skyline settings.py"
  sleep 1
  cat $WORKSPACE_DIR/skyline/settings.py > $WORKSPACE_DIR/skyline/settings.py.original
  
  
  cat $WORKSPACE_DIR/skyline/settings.py.original \
    | sed -e "s/PICKLE_PORT = .*/PICKLE_PORT = $PICKLE_PORT/g" \
    | sed -e "s/WORKER_PROCESSES = .*/WORKER_PROCESSES = $WORKER_PROCESSES/g" \
    | sed -e "s/CARBON_HOST = .*/CARBON_HOST = '$CARBON_HOST'/g" \
    | sed -e "s/CARBON_PORT = .*/CARBON_PORT = $CARBON_PORT/g" \
    | sed -e "s/GRAPHITE_PROTOCOL = .*/GRAPHITE_PROTOCOL = '$GRAPHITE_PROTOCOL'/g" \
    | sed -e "s/GRAPHITE_AUTH_HEADER = .*/GRAPHITE_AUTH_HEADER = '$GRAPHITE_AUTH_HEADER'/g" \
    | sed -e "s/GRAPHITE_HOST = .*/GRAPHITE_HOST = '$GRAPHITE_HOST'/g" \
    | sed -e "s/SLACK_ENABLED = .*/SLACK_ENABLED = $SLACK_ENABLED/g" \
    | sed -e "s/^SLACK_OPTS = .*/SLACK_OPTS = $SLACK_OPTS/g" \
    | sed -e "s/^SMTP_OPTS = .*/SMTP_OPTS = $SMTP_OPTS/g" \
    | sed -e "s/REDIS_PASSWORD = .*/REDIS_PASSWORD = '$REDIS_PASSWORD'/g" \
    | sed -e "s/WEBAPP_AUTH_USER = .*/WEBAPP_AUTH_USER = '$WEBAPP_AUTH_USER'/g" \
    | sed -e "s/WEBAPP_AUTH_USER_PASSWORD = .*/WEBAPP_AUTH_USER_PASSWORD = '$WEBAPP_AUTH_USER_PASSWORD'/g" \
    | sed -e "s/WEBAPP_ALLOWED_IPS = .*/WEBAPP_ALLOWED_IPS = ['127.0.0.1', '$YOUR_OTHER_IP_ADDRESS']/g" \
    | sed -e "s/PANORAMA_ENABLED = .*/PANORAMA_ENABLED = $PANORAMA_ENABLED/g" \
    | sed -e "s/PANORAMA_DBHOST = .*/PANORAMA_DBHOST = '$PANORAMA_DBHOST'/g" \
    | sed -e "s/PANORAMA_DBPORT = .*/PANORAMA_DBPORT = '$PANORAMA_DBPORT'/g" \
    | sed -e "s/PANORAMA_DBUSERPASS = .*/PANORAMA_DBUSERPASS = '$PANORAMA_DBUSERPASS'/g" \
    | sed -e "s/PANORAMA_DBUSER = .*/PANORAMA_DBUSER = '$PANORAMA_DBUSER'/g" \
    | sed -e "s/SKYLINE_URL = .*/SKYLINE_URL = 'https:\/\/$YOUR_SKYLINE_SERVER_FQDN'/g" \
    | sed -e 's/MEMCACHE_ENABLED = .*/MEMCACHE_ENABLED = True/g' \
    | sed -e "s/HORIZON_IP = .*/HORIZON_IP = '$YOUR_SERVER_IP_ADDRESS'/g" > $WORKSPACE_DIR/skyline/settings.py
  # | sed -e "s/HORIZON_IP = .*/HORIZON_IP = '$YOUR_SERVER_IP_ADDRESS'/g" \
fi


#### Configure Mysql container ####
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
sudo apt-get install -y mysql-server

echo "[mysqld]" >> /etc/mysql/my.cnf
echo "bind-address = *" >> /etc/mysql/my.cnf
echo " Running Test: "
sudo mysqld --verbose --help | grep bind-address

ROOT_DB_ACCESS="sudo mysql -h $PANORAMA_DBHOST -P $PANORAMA_DBPORT -u root -p$MYSQL_ROOT_PASSWORD"


SKYLINE_DB_PRESENT=$($ROOT_DB_ACCESS -sss -e "SHOW DATABASES" | grep -c skyline)
if [ $SKYLINE_DB_PRESENT -eq 0 ]; then
  echo "Deploying Skyline SQL schema"
  sleep 1
  $ROOT_DB_ACCESS < $WORKSPACE_DIR/skyline/skyline.sql
  if [ $? -ne 0 ]; then
    echo "error :: failed to deploy Skyline SQL schema"
    exit 1
  fi
else
  echo "Skipping deploying Skyline SQL schema, already done."
  sleep 1
fi

SKYLINE_DB_USER_PRESENT=$($ROOT_DB_ACCESS -sss -e "SELECT User FROM mysql.user" | sort | uniq | grep -c skyline)
if [ $SKYLINE_DB_USER_PRESENT -eq 0 ]; then
  echo "Creating skyline MySQL user and permissions"
  sleep 1
  $ROOT_DB_ACCESS -e "CREATE USER 'skyline' IDENTIFIED BY '$PANORAMA_DBUSERPASS'; GRANT ALL PRIVILEGES ON skyline.* TO 'skyline'@'%'; FLUSH PRIVILEGES;"
  if [ $? -ne 0 ]; then
    echo "error :: failed to create skyline MySQL user"
    exit 1
  fi
else
  echo "Skipping creating skyline MySQL user and permissions, already exists."
  sleep 1
fi

echo "$ROOT_DB_ACCESS -sss -e \"SHOW DATABASES\""
$ROOT_DB_ACCESS -sss -e "SHOW DATABASES"

