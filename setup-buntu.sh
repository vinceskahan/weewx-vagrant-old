
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

# git just in case we need it
sudo apt-get install -y git

# ubuntu 18.04 drops python-imaging, so we must use python-pil,
# which fortunately is available in:
#    debian 8, debian 9, ubuntu 16.04, ubuntu 17.10 

sudo apt-get install -y python-pil

# other things weewx needs
sudo apt-get install -y python-configobj python-cheetah python-serial python-usb python-dev

# optional - this will slow your install down
# sudo apt-get install -y python-pip
# sudo pip install pyephem
