
#------------- start editing here ----------------------------

# uncomment your desired method to download weewx sources

#WEEWX_DOWNLOAD_METHOD="dpkg"      # official version, dpkg
WEEWX_DOWNLOAD_METHOD="git"        # bleeding edge, setup.py
#WEEWX_DOWNLOAD_METHOD="tarball"   # official version, setup.py

# set this to match the version in the downloads directory
# which is http://www.weewx.com/downloads
#    - this is ignored for 'git' and 'dpkg' installations

WEEWX_VERSION="3.8.0"  # used for tarball installs only

# set to 1 for debug enabled
DEBUG_MODE=1

#------------- stop editing here -----------------------------


# uncomment to update everything to current
#   - commented out here to speed up my dev/test cycle
#     but you almost certainly 'do' want to upgrade
#     on your system of course
#
# sudo yum update -y

yum install -y sqlite3 wget tzdata \
    python-configobj python-cheetah \
    python-imaging python-setuptools

# to do: support pyephem for this os

# no nginx by default so use apache
yum install -y httpd
chkconfig --add httpd
service httpd start

#-------------------------------------------------------------

case "x${WEEWX_DOWNLOAD_METHOD}" in

   "xdpkg")

        # to do - put in the centos repo commands here.....

        ##--- define weewx repo for apt ---
        #echo "...defining weewx repo..."
        #wget -qO - http://weewx.com/keys.html      | sudo apt-key add -
        #wget -qO - http://weewx.com/apt/weewx.list | sudo tee /etc/apt/sources.list.d/weewx.list
        #apt-get update

        ##--- install weewx in simulator mode with no prompts ---
        #echo "...installing  weewx..."
        #DEBIAN_FRONTEND=noninteractive apt-get install -y weewx

        ## link it into the web at the top of the docroot
        #echo "...symlink to top of web docroot..."
        #sudo  ln -s /var/www/html /var/www/html/weewx

        ## set debug mode on
        #if [ "x${DEBUG_MODE}" = "x1" ]
        #then
            #sudo sed -i 's:debug = 0:debug = 1:' /etc/weewx/weewx.conf
            #sudo systemctl restart weewx
        #fi

        ;;

    *)
        #--- setup.py from git latest or a particular version ---
        echo "...downloading weewx..."
        if [ "x${WEEWX_DOWNLOAD_METHOD}" = "xgit" ]
        then
           sudo yum install -y git
           git clone https://github.com/weewx/weewx.git /tmp/weewx-current
        else
           # this assumes Tom always has his tarball with a top directory weewx-x.y.z
           wget http://www.weewx.com/downloads/weewx-${WEEWX_VERSION}.tar.gz -O /tmp/weewx.tgz
         echo "...extracting weewx..."
           cd /tmp
           tar zxf /tmp/weewx.tgz
        fi

        echo "...building weewx (simulator mode)..."
        cd /tmp/weewx-* ; ./setup.py build ; sudo ./setup.py install --no-prompt

        # link it into the web at the top of the docroot
        echo "...symlink to top of web docroot..."
        sudo  ln -s /var/www/html /home/weewx/public_html

        # put system startup file into place
        #echo "...hook weewx into systemd..."
        #sudo cp /home/weewx/util/systemd/weewx.service /etc/systemd/system
        #sudo systemctl enable weewx
        echo "...hook weewx into init.d..."
        sudo cp /home/weewx/util/init.d/weewx.redhat /etc/rc.d/init.d/weewx
        sudo chkconfig --add weewx

        # set debug mode on
        if [ "x${DEBUG_MODE}" = "x1" ]
        then
            sudo sed -i 's:debug = 0:debug = 1:' /home/weewx/weewx.conf
        fi

        # set the location to something indicating this os
        HOSTNAME=`hostname`
        sed -i -e s:Hood\ River,\ Oregon:${HOSTNAME}: /home/weewx/weewx.conf

        # light that candle
        echo "...starting weewx..."
        # sudo systemctl start weewx
        sudo service weewx start

        ;;

esac

#-------------------------------------------------------------

# that's all folks
echo "...done..."
