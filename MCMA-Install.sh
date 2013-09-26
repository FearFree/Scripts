#!/bin/bash
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
		cron="@reboot sh /home/$mcuser/start.sh\n"
		sudo -u $mcuser bash <<EOF
(crontab -l; echo "$cron" ) | crontab -
./MCMA2_Linux_x86_64 -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		ip=`hostname -i`
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
		#End
	else
		echo "32 bit operating systems not supported, exiting"
		#Insert 32 bit yum code (future)
		exit 1
	fi
#################################################################
#File has not been modified from legacy version below this point#
#################################################################

else
if [ "$system" = "apt" ]
then
	if [ "$arch" = "64" ]
	then
		echo "Initializing 64 Bit Debian System Installation..."
		apt-get -y -qq update >/dev/null 2>&1
		apt-get -y -qq install openjdk-7-jdk >/dev/null 2>&1
		apt-get -y -qq install screen >/dev/null 2>&1
		apt-get -y -qq install unzip >/dev/null 2>&1
		cd /usr/local
		wget -q http://s-l.us/mcma/etc.zip >/dev/null 2>&1
		unzip -qq etc.zip >/dev/null 2>&1
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
		cron="@reboot sh /home/$mcuser/start.sh\n"
		sudo -u $mcuser bash <<EOF
(crontab -l; echo "$cron" ) | crontab -
./MCMA2_Linux_x86_64 -nonotice -setpass $mcmapass -configonly +Java.Memory $ram +Java.VM server +McMyAdmin.FirstStart False >/dev/null 2>&1
./start.sh
EOF
		echo "Installation complete.  Please visit http:\\$ip:8080 in your web browser to continue."
		#End
    else
      echo "32 bit operating systems not supported, exiting."
      exit 1
      #Insert 32 bit debian code
    fi
  fi
fi
