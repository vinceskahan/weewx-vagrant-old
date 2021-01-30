
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
VER="4.4.0"

# set to '1' to use a released version
# set to '0' to use a development version
USE_RELEASED_VERSION=1

#------------------------------------------------------
# STOP EDITING HERE
#------------------------------------------------------

# this installs weewx itself as well as nginx
# and a couple extra packages we always install

if [ "x${USE_PACKAGE}" = "x1" ]
then
    export WEEWX_CONF="/etc/weewx/weewx.conf"

    rpm --import http://weewx.com/keys.html

    # CentOS doesn't have lsb_release so we need to do it the hard way
    source /etc/os-release
    if [ "x${VERSION_ID}" = "x7" ]
    then
        echo "VERSION_ID = ${VERSION_ID} - using centos7 repo"
        yum -y install epel-release
        yum -y install pyserial pyusb
        yum -y install python2-pip  
        curl -s http://weewx.com/yum/weewx-el7.repo | sudo tee /etc/yum.repos.d/weewx.repo
    else
        echo "VERSION_ID = ${VERSION_ID} - using centos8 repo"
        yum -y install epel-release
        yum -y install python3-cheetah
        curl -s http://weewx.com/yum/weewx-el8.repo | sudo tee /etc/yum.repos.d/weewx.repo
    fi

    sed -i -e "s:SELINUX=enforcing:SELINUX=permissive:" /etc/sysconfig/selinux
    setenforce 0
    yum install -y weewx

else
    export WEEWX_CONF="/home/weewx/weewx.conf"

    if [ "x${USE_RELEASED_VERSION}" = "x1" ]
    then
        export UPSTREAM_PATH="http://weewx.com/downloads"
    else
        export UPSTREAM_PATH="http://weewx.com/downloads/development_versions"
    fi
    export URL="${UPSTREAM_PATH}/weewx-${VER}.tar.gz"

    # CentOS doesn't have lsb_release so we need to do it the hard way
    source /etc/os-release
    if [ "x${VERSION_ID}" = "x7" ]
    then
        yum install -y epel-release
        yum install -y python3 wget curl
        pip3 install configobj
        pip3 install pillow
        pip3 install pyserial
        pip3 install pyusb
        pip3 install cheetah3
        pip3 install pyephem
    else
        yum install -y epel-release
        yum install -y python3 wget curl
        yum install -y python3-configobj
        yum install -y python3-pillow
        yum install -y python3-pyserial
        yum install -y python3-pyusb
        pip3 install cheetah3
        pip3 install pyephem
    fi

    cd /tmp
    wget ${URL}
    tar zxvf weewx-${VER}.tar.gz

    cd weewx-${VER}
    python3 setup.py build
    python3 setup.py install --no-prompt

    sed -i -e "s:SELINUX=enforcing:SELINUX=permissive:" /etc/sysconfig/selinux
    setenforce 0

    cp /home/weewx/util/systemd/weewx.service /etc/systemd/system
    systemctl enable weewx
    systemctl start weewx

fi

#--------------------------------------
# postinstall steps
#--------------------------------------

yum -y install git vim nginx

if [ x"${USE_SETUP}" = "x1" ]
then
    export WEEWX_HTML="/home/weewx/public_html"
    ln -s ${WEEWX_HTML} /usr/share/nginx/html/weewx
else
    export WEEWX_HTML="/var/www/html/weewx"
    ln -s ${WEEWX_HTML} /usr/share/nginx/html/weewx
fi

systemctl enable nginx
systemctl start  nginx

# this comes from /etc/os-release
sed -i -e "s:Hood River, Oregon:${PRETTY_NAME}:"            ${WEEWX_CONF}
sed -i -e "s:My Little Town, Oregon:${PRETTY_NAME}:"        ${WEEWX_CONF}
sed -i -e "s:Santa's Workshop, North Pole:${PRETTY_NAME}:"  ${WEEWX_CONF}

sed -i -e "s:latitude = 90.000:latitude = 47.310:"          ${WEEWX_CONF}
sed -i -e "s:longitude = 0.000:longitude = -122.360:"       ${WEEWX_CONF}

sed -i -e "s:latitude = 0.00:latitude = 47.310:"            ${WEEWX_CONF}
sed -i -e "s:longitude = 0.00:longitude = -122.360:"        ${WEEWX_CONF}

sed -i -e "s:debug = 0:debug = 1:"                          ${WEEWX_CONF}
sed -i -e "s:altitude = 0, meter:altitude = 365, foot:"     ${WEEWX_CONF}
sed -i -e "s:altitude = 700, foot:altitude = 365, foot:"    ${WEEWX_CONF}

systemctl restart weewx


