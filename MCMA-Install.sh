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
      yum update >/dev/null 2>&1
	  yum -y -q install java-1.7.0-openjdk.x86_64
      yum -y -q install screen >/dev/null 2>&1
      yum -y -q install unzip >/dev/null 2>&1

	  cd /usr/local
      wget http://mcmyadmin.com/Downloads/etc.zip
      unzip -qq etc.zip
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
	  #Do the following with sudo -u to non-root user
	  cd /home/$mcuser
      sudo -u $mcuser wget -q http://mcmyadmin.com/Downloads/MCMA2_glibc25.zip
      sudo -u $mcuser unzip -qq MCMA-glibc25.zip >/dev/null 2>&1
      rm -f MCMA2-glibc.zip
	 
 	  sudo -u bot cat > /home/$mcuser/start.sh << EOF
#!/bin/bash

cd /home/$mcuser
screen -dmS MCMA ./MCMA2_Linux_x86_64
EOF
     
	  echo "Setting Up McMyAdmin Auto-Start..."
	  cron="@reboot sh /home/$mcuser/start.sh"
	  sudo -u $mcuser (crontab -l; echo "$cron" ) | crontab -

	  sudo -u $mcuser ./MCMA2_Linux_x86_64 -setpass $mcmapass -configonly
 #Finish this....
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
      #Insert 64 bit debian code
      apt-get -y -qq update >/dev/null 2>&1
      echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu lucid main" >> /etc/apt/sources.list
      apt-get -y -qq update >/dev/null 2>&1
      apt-key adv --recv-keys --keyserver keyserver.ubuntu.com key-fingerprint >/dev/null 2>&1
      apt-get -y -qq install oracle-java7-installer --force-yes >/dev/null 2>&1
      apt-get -y -qq install screen >/dev/null 2>&1
      apt-get -y -qq install unzip >/dev/null 2>&1
      cd /root
      wget -q http://s-l.us/mcma/McMyAdmin2.zip >/dev/null 2>&1
      unzip -qq McMyAdmin2.zip >/dev/null 2>&1
      rm -f McMyAdmin2.zip
      cd /usr/local
      wget -q http://s-l.us/mcma/etc.zip >/dev/null 2>&1
      unzip -qq etc.zip >/dev/null 2>&1

      echo "Setting Up McMyAdmin Auto-Start..."
      cat > /root/start.sh << EOF
#!/bin/bash

cd /root
screen -dmS MCMA ./MCMA2_Linux_x86_64
EOF

      cat >> /etc/crontab << EOF
 #
@reboot root sh /root/start.sh
#
EOF

    echo "Configuring McMyAdmin"
cat >> /root/McMyAdmin.conf << EOF
 #Automated variables below
java.memory=512
login.username=FearFree
mcmyadmin.licencekey=
login.passwordmd5=60474c9c10d7142b7508ce7a50acf414

limits.maxplayers=1024
EOF

      chmod -R 744 /root/
      echo "Automated System Reboot in 5 seconds..."
      sleep 5
      shutdown -r now

    else
      echo "32 bit operating systems not supported, exiting."
      exit 1
      #Insert 32 bit debian code
    fi
  fi
fi
