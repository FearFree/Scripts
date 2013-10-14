#!/bin/bash

#This script will install McMyAdmin, and all of it's dependencies.
#It was made for new OS installs, but can be run on any supported 
#system.
#
#Tested on CentOS 6.4 (64 & 32 bit), CentOS 5.8 (64 & 32 bit), Ubuntu 13.04 (64 & 32 bit), & Debian 7 (64 & 32 bit)
#
#If you run this script more than once, be sure and check your MCMA user's crontab for duplicate entries.
#
#Copyright 2013 Nick Amsbaugh

if [ $USER != "root" ]
then
	echo "You must run this script as root."
	exit 1
fi
arch=`uname -m`
if command -v yum update >/dev/null
then
	system="yum"
	echo "Yum Package Manager Detected"
	sleep 1
	if [ "$arch" = "x86_64" ]
	then
		echo "64 Bit Detected"
		arch="64"
		sleep 1
	else
		echo "32 Bit Detected"
		arch="32"
		sleep 1
	fi
else
	if command -v apt-get update >/dev/null
	then
		system="apt"
		echo "Apt-Get Package Manager Detected"
		sleep 1
		if [ "$arch" = "x86_64" ]
		then
			echo "64 Bit Detected"
			arch="64"
			sleep 1
		else
			echo "32 Bit Detected"
			arch="32"
			sleep 1
		fi
	else
		echo "Unable to determins package manager, exiting"
		system="Unknown"
		exit 1
	fi
fi

if [ "$system" = "yum" ]
then
	if [ "$arch" = "64" ]
	then
		echo "Initializing 64 Bit RHEL Based System Installation..."
		read -p "Non-root user to run McMyAdmin as: " mcuser
		read -p "Please enter password for this user (leave blank if user already exists): " mcpass
		read -p "Please enter the password you would like for McMyAdmin's admin user: " mcmapass
		read -p "How much RAM would you like to allocate to the Minecraft server, in MB (1024MB per GB): " ram
		#Add more variables as needed for MCMA config
		echo "Starting installation, this make take a few minutes..."
		yum -y update >/dev/null 2>&1
		yum -y -q install java-1.7.0-openjdk.x86_64 >/dev/null 2>&1
		yum -y -q install screen >/dev/null 2>&1
		yum -y -q install unzip >/dev/null 2>&1
		cd /usr/local
		wget -q http://mcmyadmin.com/Downloads/etc.zip >/dev/null 2>&1
		unzip -qq -o etc.zip >/dev/null 2>&1
		rm -f etc.zip
		ret=false
		getent passwd $mcuser >/dev/null 2>&1 && ret=true
		if $ret; then
			echo "The non-root user you specified already exists, continuing..."
		else
			echo "The non-root user you specified does not yet exist, creating..."
			adduser $mcuser
			echo -e "$mcpass\n$mcpass" | (passwd --stdin $mcuser)
		fi
		cd /home/$mcuser
		sudo -u $mcuser wget -q http://mcmyadmin.com/Downloads/MCMA2_glibc25.zip >/dev/null 2>&1
		sudo -u $mcuser unzip -qq -o MCMA2_glibc25.zip >/dev/null 2>&1
		rm -f MCMA2_glibc25.zip
		echo "Setting Up McMyAdmin Auto-Start..."
		sudo -u $mcuser cat > /home/$mcuser/start.sh << EOF
#!/bin/bash

cd /home/$mcuser
screen -dmS MCMA ./MCMA2_Linux_x86_64
EOF
		chmod +x start.sh
		cron="@reboot sh /home/$mcuser/start.sh"
		sudo -u $mcuser bash <<EOF
(crontab -l; echo "$cron" ) | crontab -
./MCMA2_Linux_x86_64 -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		ip=`hostname -i`
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
		#End
	else
		#32 bit yum installation
		echo "32 bit operating systems are untested.  Proceed with caution..."
		read -p "This script will download the necessary dependencies to compile Mono from a source package, this process may take an hour or more.  If you do not wish to continue, please press CTRL-C now, or press any key to begin." -n1 -s
		echo "Initializing 32 Bit RHEL Based System Installation..."
		read -p "Non-root user to run McMyAdmin as: " mcuser
		read -p "Please enter password for this user (leave blank if user already exists): " mcpass
		read -p "Please enter the password you would like for McMyAdmin's admin user: " mcmapass
		read -p "How much RAM would you like to allocate to the Minecraft server, in MB (1024MB per GB): " ram
		#Add more variables as needed for MCMA config
		echo "Downloading dependencies to compile Mono from source..."
		wget -q http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
		rpm -Uvh epel-release-6-8.noarch.rpm >/dev/null 2>&1
		yum -y -q update >/dev/null 2>&1
		yum -y -q install bison gettext glib2 freetype fontconfig libpng libpng-devel libX11 libX11-devel glib2-devel libgdi* libexif glibc-devel urw-fonts java unzip gcc gcc-c++ automake autoconf libtool make bzip2 wget >/dev/null 2>&1
		cd /usr/local/src
		wget -q http://download.mono-project.com/sources/mono/mono-2.10.8.tar.gz
		tar zxvf mono-2.10.8.tar.gz >/dev/null 2>&1
		cd mono-2.10.8
		echo "Mono configuration beginning, this will take a significant amount of time.  Intentionally left verbose so you can see it is still running..."
		sleep 1
		./configure --prefix=/usr/local 
		make && make install
		mv /usr/local/bin/mono /usr/bin/mono >/dev/null 2>&1
		
		echo "Starting package installation, this make take a few minutes..."
		yum -y -q update
		yum -y -q install java-1.7.0-openjdk
		yum -y -q install screen
		yum -y -q install unzip
		if id -u $mcuser >/dev/null 2>&1; then
			echo "The non-root user you specified already exists, continuing..."
		else 
			echo "The non-root user you specified does not yet exist, creating..."
			adduser $mcuser
			echo -e "$mcpass\n$mcpass" | (passwd --stdin $mcuser)
		fi
		cd /home/$mcuser
		sudo -u $mcuser wget -q wget http://mcmyadmin.com/Downloads/MCMA2-Latest.zip
		sudo -u $mcuser unzip -qq -o MCMA2-Latest.zip
		rm -f MCMA2-Latest.zip
		echo "Setting Up McMyAdmin Auto-Start..."
		sudo -u $mcuser cat > /home/$mcuser/start.sh << EOF
#!/bin/bash

cd /home/$mcuser
screen -dmS MCMA mono McMyAdmin.exe
EOF
		chmod +x start.sh
		chown $mcuser:$mcuser start.sh
		cron="@reboot sh /home/$mcuser/start.sh"
		sudo -u $mcuser bash <<EOF
cd /home/$mcuser
(crontab -l; echo "$cron" ) | crontab -
mono McMyAdmin.exe -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		ip=`hostname -i`
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
		#End
	fi
else
if [ "$system" = "apt" ]
then
	if [ "$arch" = "64" ]
	then
		echo "Initializing 64 Bit Debian System Installation..."
		read -p "Non-root user to run McMyAdmin as.  This can be an existing user, or one that this script will create: " mcuser
		read -p "Please enter password for this user (leave blank if user already exists): " mcpass
		read -p "Please enter the password you would like for McMyAdmin's admin user: " mcmapass
		read -p "How much RAM would you like to allocate to the Minecraft server, in MB (1024MB per GB): " ram
		#Add more variables as needed for MCMA config
		echo "Starting installation, this make take a few minutes..."
		apt-get -y -qq update >/dev/null 2>&1
		apt-get -y -qq install openjdk-7-jdk >/dev/null 2>&1
		apt-get -y -qq install screen >/dev/null 2>&1
		apt-get -y -qq install unzip >/dev/null 2>&1
		cd /usr/local
		wget -q http://mcmyadmin.com/Downloads/etc.zip >/dev/null 2>&1
		unzip -o -qq etc.zip >/dev/null 2>&1
		rm -f etc.zip
		ret=false
		getent passwd $mcuser >/dev/null 2>&1 && ret=true
		if $ret; then
			echo "The non-root user you specified already exists, continuing..."
		else
			echo "The non-root user you specified does not yet exist, creating..."
			useradd -m $mcuser
			echo $mcuser:$mcpass | chpasswd
		fi
		cd /home/$mcuser
		sudo -u $mcuser wget -q http://mcmyadmin.com/Downloads/MCMA2_glibc25.zip >/dev/null 2>&1
		sudo -u $mcuser unzip -qq -o MCMA2_glibc25.zip >/dev/null 2>&1
		rm -f MCMA2_glibc25.zip
		echo "Setting Up McMyAdmin Auto-Start..."
		sudo -u $mcuser cat > /home/$mcuser/start.sh << EOF
#!/bin/bash

cd /home/$mcuser
screen -dmS MCMA ./MCMA2_Linux_x86_64
EOF
		chmod +x start.sh
		cron="@reboot sh /home/$mcuser/start.sh"
		sudo -u $mcuser bash <<EOF
(crontab -l; echo "$cron" ) | crontab -
./MCMA2_Linux_x86_64 -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
		#End
    else
        echo "32 bit operating systems are untested, proceed with caution..."
	    echo "Initializing 32 Bit Debian System Installation..."
	    read -p "Non-root user to run McMyAdmin as.  This can be an existing user, or one that this script will create: " mcuser
	    read -p "Please enter password for this user (leave blank if user already exists): " mcpass
	    read -p "Please enter the password you would like for McMyAdmin's admin user: " mcmapass
	    read -p "How much RAM would you like to allocate to the Minecraft server, in MB (1024MB per GB): " ram
		#Add more variables as needed for MCMA config
		echo "Starting installation, this make take a few minutes..."
		apt-get -y -qq update >/dev/null 2>&1
		apt-get -y -qq install libmono-system-web2.0-cil libmono-i18n2.0-cil >/dev/null 2>&1
		apt-get -y -qq install openjdk-7-jdk >/dev/null 2>&1
		apt-get -y -qq install screen >/dev/null 2>&1
		apt-get -y -qq install unzip >/dev/null 2>&1
		
		ret=false
		getent passwd $mcuser >/dev/null 2>&1 && ret=true
		if $ret; then
			echo "The non-root user you specified already exists, continuing..."
		else
			echo "The non-root user you specified does not yet exist, creating..."
			useradd -m $mcuser
			echo $mcuser:$mcpass | chpasswd
		fi
		cd /home/$mcuser
		sudo -u $mcuser wget -q http://mcmyadmin.com/Downloads/MCMA2-Latest.zip >/dev/null 2>&1
		sudo -u $mcuser unzip -qq -o MCMA2-Latest.zip >/dev/null 2>&1
		rm -f MCMA2-Latest.zip
		echo "Setting Up McMyAdmin Auto-Start..."
		sudo -u $mcuser cat > /home/$mcuser/start.sh << EOF
#!/bin/bash

cd /home/$mcuser
screen -dmS MCMA mono McMyAdmin.exe
EOF
		chmod +x start.sh
		chown $mcuser:$mcuser start.sh
		cron="@reboot sh /home/$mcuser/start.sh"
		sudo -u $mcuser bash <<EOF
cd /home/$mcuser
(crontab -l; echo "$cron" ) | crontab -
mono McMyAdmin.exe -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
    fi
  fi
fi
