#!/bin/bash
#
PACKAGES="openjdk-7-jdk mysql-server"
haveProg() {
    [ -x "$(which $1)" ]
}

if haveProg apt-get ; then func_apt-get
elif haveProg yum ; then func_apt-yum
elif haveProg up2date ; then func_up2date
else
    echo 'No package manager found!'
    exit 2
fi

func_apt-get() {
           sudo apt-get install $PACKAGES
}

func_yum() {
           sudo yum install $PACKAGES
}