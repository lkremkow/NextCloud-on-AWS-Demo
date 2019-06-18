TARGETHOST = 1.1.1.1
TARGETPORT = 22
TARGETUSER = admin
AWSIDFILE = ~/.ssh/KeyFile.pem

EXECCMD = ssh -i ${AWSIDFILE} -p ${TARGETPORT} ${TARGETUSER}@${TARGETHOST}
SCPCMD = scp -i ${AWSIDFILE} -P ${TARGETPORT}

all: configure_apache
	#
	# all - success

test_connection:
	#
	# test connection
	${EXECCMD} 'echo "we are able to connect"'

update_os: test_connection
	#
	# update OS
	${EXECCMD} 'sudo apt-get -y update'
	${EXECCMD} 'sudo apt-get -y upgrade'

install_packages: update_os
	#
	# install packages
	${EXECCMD} 'sudo apt-get -y install curl unzip wget bzip2'
	${EXECCMD} 'sudo apt-get -y install apache2'
	${EXECCMD} 'sudo apt-get -y install php7.0 php7.0-dom php7.0-gd php7.0-mbstring php7.0-zip php7.0-mysql php7.0-curl php7.0-bz2 php7.0-intl php7.0-mcrypt php-imagick'

install_ssl_certificates: configure_efs_mount
	#
	# install SSL certificates
	${SCPCMD} ncaws-certs.tar ${TARGETUSER}@${TARGETHOST}:/tmp
	${EXECCMD} 'if [[ -d /etc/ssl/ncaws.tftg.net ]]; then sudo rm -rf /etc/ssl/ncaws.tftg.net; fi'
	${EXECCMD} 'sudo mkdir /etc/ssl/ncaws.tftg.net'
	${EXECCMD} 'sudo tar -xf /tmp/ncaws-certs.tar --directory=/etc/ssl/ncaws.tftg.net'
	${EXECCMD} 'rm /tmp/ncaws-certs.tar'

replace_default_site: install_ssl_certificates
	#
	# replace default site
	${SCPCMD} default-no-content-index.html ${TARGETUSER}@${TARGETHOST}:/tmp
	${EXECCMD} 'sudo rm -rf /var/www/html/*'
	${EXECCMD} 'sudo cp /tmp/default-no-content-index.html /var/www/html/index.html'
	${EXECCMD} 'rm /tmp/default-no-content-index.html'
	${EXECCMD} 'sudo chown -R www-data.www-data /var/www/html'

install_nextcloud_apache_conf: replace_default_site
	#
	# install NextCloud Apache configuration
	${EXECCMD} 'if [[ ! -d /var/www/ncaws.tftg.net ]]; then sudo mkdir /var/www/ncaws.tftg.net; fi'
	${EXECCMD} 'sudo chown www-data.www-data /var/www/ncaws.tftg.net'
	${SCPCMD} apache-ncaws.tftg.net.conf ${TARGETUSER}@${TARGETHOST}:/tmp
	${EXECCMD} 'sudo cp /tmp/apache-ncaws.tftg.net.conf /etc/apache2/sites-available/nextcloud.conf'
	${EXECCMD} 'rm /tmp/apache-ncaws.tftg.net.conf'
	${EXECCMD} 'sudo a2ensite nextcloud'

configure_apache: install_nextcloud_site
	#
	# configure Apache
	${EXECCMD} 'sudo a2enmod ssl'
	${EXECCMD} 'sudo a2enmod rewrite'
	${EXECCMD} 'sudo a2enmod headers'
	${EXECCMD} 'sudo a2enmod env'
	${EXECCMD} 'sudo a2enmod dir'
	${EXECCMD} 'sudo a2enmod mime'
	${EXECCMD} 'sudo systemctl enable apache2.service'
	${EXECCMD} 'sudo systemctl restart apache2.service'

configure_nextcloud_site:
	#
	# configure NextCloud site
	# used to set S3 as unique global storage
	${SCPCMD} nextcloud-config.php ${TARGETUSER}@${TARGETHOST}:/tmp
	${EXECCMD} 'sudo cp /tmp/nextcloud-config.php /var/www/ncaws.tftg.net/config/config.php'
	${EXECCMD} 'sudo chown -R www-data.www-data /var/www/ncaws.tftg.net'
	${EXECCMD} 'if [[ -f /tmp/nextcloud-config.php ]]; then rm /tmp/nextcloud-config.php; fi'

install_nextcloud_site: install_nextcloud_apache_conf
	#
	# install NextCloud site
	${EXECCMD} 'if [[ -d /var/www/ncaws.tftg.net ]]; then sudo rm -rf /var/www/ncaws.tftg.net; fi'
	${EXECCMD} 'sudo mkdir /var/www/ncaws.tftg.net'
	${EXECCMD} 'sudo mkdir /var/www/ncaws.tftg.net/data'
	${EXECCMD} 'if [[ -f /tmp/nextcloud.tar.bz2 ]]; then rm /tmp/nextcloud.tar.bz2; fi'
	${EXECCMD} 'curl --silent --output /tmp/nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/nextcloud-15.0.8.tar.bz2'
	${EXECCMD} 'tar -xjf /tmp/nextcloud.tar.bz2 --directory=/tmp'
	${EXECCMD} 'sudo cp -r /tmp/nextcloud/* /var/www/ncaws.tftg.net'
	${EXECCMD} 'sudo chown -R www-data.www-data /var/www/ncaws.tftg.net'
	${EXECCMD} 'if [[ -f /tmp/nextcloud.tar.bz2 ]]; then rm /tmp/nextcloud.tar.bz2; fi'
	${EXECCMD} 'if [[ -d /tmp/nextcloud ]]; then rm -rf /tmp/nextcloud; fi'

install_cloud_agent:
	#
	# install Qualys Cloud Agent
	${EXECCMD} 'if [[ -f /tmp/qualys-cloud-agent.x86_64.deb ]]; then rm /tmp/qualys-cloud-agent.x86_64.deb; fi'
	${SCPCMD} qualys-cloud-agent.x86_64.deb ${TARGETUSER}@${TARGETHOST}:/tmp
	${EXECCMD} sudo dpkg --install /tmp/qualys-cloud-agent.x86_64.deb
	${EXECCMD} 'sudo /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa CustomerId=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
	${EXECCMD} 'sudo systemctl stop qualys-cloud-agent.service'

configure_efs_mount: install_packages
	#
	# configure EFS mount
	${EXECCMD} 'sudo apt-get -y install nfs-common'
	${EXECCMD} 'sudo mkdir -p /mnt/efs'
	${EXECCMD} 'if grep --silent fs-aaaaaaaa /etc/fstab; then echo "fstab already configured; not making a change"; else echo "fs-aaaaaaaa.efs.eu-west-1.amazonaws.com:/   /mnt/efs   nfs   defaults,_netdev   0   0" | sudo tee -a /etc/fstab > /dev/null; fi'
	${EXECCMD} 'sudo mount /mnt/efs'
	${EXECCMD} 'sudo mkdir -p /mnt/efs/data'
	${EXECCMD} 'sudo chown www-data.www-data /mnt/efs/data'
