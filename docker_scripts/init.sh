cd $WORKSPACE_DIR
echo "Workspace directory:"
echo $PWD 

mkdir -p /var/log/skyline
mkdir -p /var/run/skyline
mkdir -p /var/dump
mkdir -p /opt/skyline/panorama/check
mkdir -p /opt/skyline/mirage/check
mkdir -p /opt/skyline/crucible/check
mkdir -p /opt/skyline/crucible/data
mkdir -p /opt/skyline/ionosphere/check
mkdir -p /etc/skyline
mkdir -p /tmp/skyline

cp $WORKSPACE_DIR/etc/skyline_docker.conf /etc/skyline/skyline.conf
bash $WORKSPACE_DIR/docker_scripts/configure.sh

service apache2 restart
systemctl restart memcached

$WORKSPACE_DIR/bin/horizon.d start
$WORKSPACE_DIR/bin/analyzer.d start
$WORKSPACE_DIR/bin/webapp.d start

# Panorama 
$WORKSPACE_DIR/bin/panorama.d start
$WORKSPACE_DIR/bin/ionosphere.d start
$WORKSPACE_DIR/bin/luminosity.d start

tail -f /var/log/skyline/*
