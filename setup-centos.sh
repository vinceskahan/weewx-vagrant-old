
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

