########################################################################
#
# quick provisioning script for weewx on debian(ish) systems
#    2018-0402 - vinceskahan@gmail.com - weewx 3.8.0
#
# this is in a provisioner shell script so that it can be run
# standalone 'outside' vagrant with identical results
#
# tested with debian jesse   (8)
#                    stretch (9)
#
# tested with ubuntu xenial (16.04)
#                    artful (17.10)
#                    bionic (18.04)
#
# NOTE: as of 2018-0402 and weewx-3.8.0, the dpkg method does not work
#       on ubuntu bionic 18.04 - you must use setup.py for this currently
#
# I've also noticed that vm synched folders are not configured
# in the debian vagrant boxes, so make sure to not define them
# in your Vagrantfile.  See the Vagrantfile for details...

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

# learn the upstream repo contents
sudo apt-get update -y

# uncomment to update everything to current
#   - commented out here to speed up my dev/test cycle
#     but you almost certainly 'do' want to upgrade
#     on your system of course
#
# sudo apt-get upgrade

# get ancillary stuff not always in the vagrant base box
sudo apt-get install -y sqlite3 lynx wget curl procps nginx ntp

# make sure python 2.x is there 
sudo apt-get install -y python-minimal

# ubuntu 18.04 drops python-imaging, so we must use python-pil,
# which fortunately is available in:
#    debian 8, debian 9, ubuntu 16.04, ubuntu 17.10 

sudo apt-get install -y python-pil

# other things weewx needs
sudo apt-get install -y python-configobj python-cheetah python-serial python-usb python-dev

# optional - this will slow your install down
# sudo apt-get install -y python-pip
# sudo pip install pyephem

#-------------------------------------------------------------

case "x${WEEWX_DOWNLOAD_METHOD}" in

   "xdpkg")

        #--- define weewx repo for apt ---
        echo "...defining weewx repo..."
        wget -qO - http://weewx.com/keys.html      | sudo apt-key add -
        wget -qO - http://weewx.com/apt/weewx.list | sudo tee /etc/apt/sources.list.d/weewx.list
        apt-get update

        #--- install weewx in simulator mode with no prompts ---
        echo "...installing  weewx..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y weewx

        # link it into the web at the top of the docroot
        echo "...symlink to top of web docroot..."
        sudo  ln -s /var/www/html /var/www/html/weewx

        # set debug mode on
        if [ "x${DEBUG_MODE}" = "x1" ]
        then
            sudo sed -i 's:debug = 0:debug = 1:' /etc/weewx/weewx.conf
            sudo systemctl restart weewx
        fi

        ;;

    *)
        #--- setup.py from git latest or a particular version ---
        echo "...downloading weewx..."
        if [ "x${WEEWX_DOWNLOAD_METHOD}" = "xgit" ]
        then
           sudo apt-get install -y git
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
        echo "...hook weewx into systemd..."
        sudo cp /home/weewx/util/systemd/weewx.service /etc/systemd/system
        sudo systemctl enable weewx

        # set debug mode on
        if [ "x${DEBUG_MODE}" = "x1" ]
        then
            sudo sed -i 's:debug = 0:debug = 1:' /home/weewx/weewx.conf
        fi

        # light that candle
        echo "...starting weewx..."
        sudo systemctl start weewx

        ;;

esac

#-------------------------------------------------------------

# that's all folks
echo "...done..."
