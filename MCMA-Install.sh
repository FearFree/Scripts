#!/bin/bash
#
PACKAGES="openjdk-7-jdk mysql-server"
haveProg() {
    [ -x "$(which $1)" ]
}

if haveProg apt-get ; then func_apt-get
elif haveProg yum ; then func_apt-yum
else
    echo 'No package manager found!'
    exit 2
fi

func_apt-get() {
	echo "Apt-get package manager detected, continuing..."
	sudo apt-get -qq install $PACKAGES
}

func_yum() {
	echo "Yum package manager detected, continuing..."
	sudo yum install -qq $PACKAGES
}