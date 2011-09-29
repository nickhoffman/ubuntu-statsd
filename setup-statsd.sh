# install git
sudo apt-get install g++ curl libssl-dev apache2-utils
sudo apt-get install git-core
# download the Node source, compile and install it
git clone https://github.com/joyent/node.git
cd node
./configure
make
sudo make install
# install the Node package manager for later use
curl http://npmjs.org/install.sh | sudo sh
npm install express
# clone the statsd project
git clone https://github.com/etsy/statsd.git
# download everything for graphite
mkdir graphite
cd graphite/
wget "http://launchpad.net/graphite/trunk/0.9.6/+download/carbon-0.9.6.tar.gz"
wget "http://launchpad.net/graphite/trunk/0.9.6/+download/whisper-0.9.6.tar.gz"
wget "http://launchpad.net/graphite/trunk/0.9.6/+download/graphite-web-0.9.6.tar.gz"
tar xzvf whisper-0.9.6.tar.gz 
tar xzvf carbon-0.9.6.tar.gz 
tar xzvf graphite-web-0.9.6.tar.gz
# install whisper - Graphite's DB system
cd whisper-0.9.6
sudo python setup.py install
popd
# install carbon - the Graphite back-end
cd carbon-0.9.6
python setup.py install
cd /opt/graphite/conf
cp carbon.conf.example carbon.conf
# copy the example schema configuration file, and then configure the schema
# see: http://graphite.wikidot.com/getting-your-data-into-graphite
cp storage-schemas.conf.example storage-schemas.conf
# install other graphite dependencies
sudo apt-get install python-cairo
sudo apt-get install python-django
sudo apt-get install memcached
sudo apt-get install python-memcache
sudo apt-get install python-ldap
sudo apt-get install python-twisted
sudo apt-get install apache2 libapache2-mod-python
cd ~/graphite/graphite-web-0.9.6
python setup.py install
# copy the graphite vhost example to available sites, edit it to you satisfaction, then link it from sites-enabled
cp example-graphite-vhost.conf /etc/apache2/sites-available/graphite.conf
ln -s /etc/apache2/sites-available/graphite.conf /etc/apache2/sites-enabled/graphite.conf
apache2ctl restart
# I had to create these log files manually 
/opt/graphite/storage/log/webapp
touch info.log
chmod 777 info.log
touch exception.log
chmod 777 exception.log
# make sure to change ownership of the storage folder to the Apache user/group - mine was www-data
sudo chown -R www-data:www-data /opt/graphite/storage/
cd /opt/graphite/webapp/graphite
# copy the local_settings example file to creating the app's settings
# this is where both carbon federation and authentication is configured
cp local_settings.py.example local_settings.py
# run syncdb to setup the db and prime the authentication model (if you're using the DB model)
sudo python manage.py syncdb
# start the carbon cache
cd /opt/graphite/bin/carbon-cache.py start
# copy the the statsd config example to create the config file
# unless you used non-default ports for some other feature of the system, the defaults in the config file are fine
cd ~/statsd
cp exampleConfig.js local.js
# start statsd
node stats.js local.js