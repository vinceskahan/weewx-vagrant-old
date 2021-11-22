
#------------------------------------------------------
# specify how we want to install weewx
#    (set only 'one' of these to '1')
#------------------------------------------------------

USE_PACKAGE=1
USE_SETUP=0

#------------------------------------------------------
#    if you USE_SETUP above please verify these items
#      (these are ignored if you USE_PACKAGE above)
#------------------------------------------------------

# pick your desired version
VER="4.5.1"

# set to '1' to use a released version
# set to '0' to use a development version
USE_RELEASED_VERSION=1

#------------------------------------------------------
# STOP EDITING HERE
#------------------------------------------------------

# turn off multipathd or ubuntu2004 logs incessantly and endlessly
systemctl disable multipathd.service
systemctl stop    multipathd.service

apt-get update
apt-get install -y gnupg

# this installs weewx itself as well as nginx
# and a couple extra packages we always install

if [ "x${USE_PACKAGE}" = "x1" ]
then
    export WEEWX_CONF="/etc/weewx/weewx.conf"

    wget -qO - http://weewx.com/keys.html | sudo gpg --dearmor > /etc/apt/trusted.gpg.d/weewx.gpg

    # unfortunately ubuntu1804 needs the python2 weewx package
    OS_CODENAME=`lsb_release -c | awk '{print $2}'`
    if [ "x${OS_CODENAME}" = "xbionic" ]
    then
        echo "OS_CODENAME = ${OS_CODENAME} - using python2 dpkg"
        wget -qO - http://weewx.com/apt/weewx-python2.list | sudo tee /etc/apt/sources.list.d/weewx.list
    else
        echo "OS_CODENAME = ${OS_CODENAME} - using python3 dpkg"
        wget -qO - http://weewx.com/apt/weewx-python3.list | sudo tee /etc/apt/sources.list.d/weewx.list
    fi
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y weewx
else
    export WEEWX_CONF="/home/weewx/weewx.conf"

    if [ "x${USE_RELEASED_VERSION}" = "x1" ]
    then
        export UPSTREAM_PATH="http://weewx.com/downloads"
    else
        export UPSTREAM_PATH="http://weewx.com/downloads/development_versions"
    fi
    export URL="${UPSTREAM_PATH}/weewx-${VER}.tar.gz"
    
    apt-get update
    apt-get -y install python3-configobj
    apt-get -y install python3-pil
    apt-get -y install python3-serial
    apt-get -y install python3-usb
    apt-get -y install python3-pip
    apt-get -y install python3-ephem
    apt-get -y install python3-cheetah
    retval=$?
    if [ "x${retval}" != "x0" ]
    then
        echo "# CHEETAH3 PACKAGE NOT AVAILABLE - USING PIP3 (retval=${retval})"
        pip3 install cheetah3
    else
        echo "# CHEETAH3 PACKAGE INSTALLED"
    fi
    
    
    # do not 'apt-get upgrade' in a provisioner
    # as debian asks a question re: grub 
    # and the provisioner will hang
    
    cd /tmp
    wget ${URL}
    tar zxvf weewx-${VER}.tar.gz
    
    cd weewx-${VER}
    python3 setup.py build
    python3 setup.py install --no-prompt
    
    cp /home/weewx/util/systemd/weewx.service /etc/systemd/system
    systemctl enable weewx
    systemctl start weewx

fi

#--------------------------------------
# postinstall steps
#--------------------------------------

apt-get -y install git vim nginx

if [ x"${USE_SETUP}" = "x1" ]
then
    export WEEWX_HTML="/home/weewx/public_html"
    ln -s ${WEEWX_HTML} /var/www/html/weewx
fi

HOSTNAME=`hostname`
sed -i -e "s:Hood River, Oregon:${HOSTNAME}:"            ${WEEWX_CONF}
sed -i -e "s:My Little Town, Oregon:${HOSTNAME}:"        ${WEEWX_CONF}
sed -i -e "s:Santa's Workshop, North Pole:${HOSTNAME}:"  ${WEEWX_CONF}

sed -i -e "s:latitude = 90.000:latitude = 47.310:"       ${WEEWX_CONF}
sed -i -e "s:longitude = 0.000:longitude = -122.360:"    ${WEEWX_CONF}

sed -i -e "s:latitude = 0.00:latitude = 47.310:"        ${WEEWX_CONF}
sed -i -e "s:longitude = 0.00:longitude = -122.360:"    ${WEEWX_CONF}

sed -i -e "s:debug = 0:debug = 1:"                               ${WEEWX_CONF}
sed -i -e "s:altitude = 0, meter:altitude = 365, foot:"          ${WEEWX_CONF}
sed -i -e "s:altitude = 700, foot:altitude = 365, foot:"  ${WEEWX_CONF}

systemctl restart weewx


