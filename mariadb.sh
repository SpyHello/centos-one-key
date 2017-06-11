#!/usr/bin/env bash
yum update -y
yum groupinstall -y Development Tools
# ubuntu : libncurses5-dev
yum install -y cmake ncurses-devel openssl-devel openssl

source ./include.sh

# install mysql
mysql_dir="/home/srv/mariadb"
mysql_installdir="/home/srv/install/mariadb"
mysql_datadir="/home/srv/mariadb/data"
mysql_logdir="/home/srv/mariadb/data/log"
mysql_passwd="lich4tung"
mariadb="mariadb-10.2.6"
# http://mirrors.neusoft.edu.cn/mariadb//mariadb-10.2.6/source/mariadb-10.2.6.tar.gz


cd /root/
# 客户可能已经存在
useradd -M -s /sbin/nologin mysql
mkdir -p ${mysql_dir}
chown mysql.mysql -R ${mysql_dir}
mkdir -p ${mysql_datadir}
chown mysql.mysql -R ${mysql_datadir}
copy ${CURRENT_DIR}/conf/my.cnf ${mysql_dir}/my.cnf
if [ ! -d ${mysql_installdir}/${mariadb} ]; then
    if [ ! -f ${mysql_installdir}/${mariadb}.tar.gz ]; then
        download ${mysql_installdir}/${mariadb}.tar.gz  "http://mirrors.neusoft.edu.cn/mariadb//${mariadb}/source/${mariadb}.tar.gz"
    fi
    cd ${mysql_installdir}/
    tar -zxf ${mariadb}.tar.gz
fi


cd ${mysql_installdir}/${mariadb}
cmake . -DCMAKE_INSTALL_PREFIX=${mysql_dir}/ \
-DMYSQL_DATADIR=${mysql_datadir} \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=17001 \
-DWITH_SSL=system \
-DWITH_ZLIB=system \
-DWITH_LIBWRAP=0 \
-DCMAKE_THREAD_PREFER_PTHREAD=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DWITH_DEBUG=0 -with-low-memory


# How to Fix PHP Configure “CC Internal error Killed (program cc1)” Error
# http://linux.101hacks.com/unix/fix-php-cc-internal-errror-killed/

make && make install
rm -rf /etc/my.cnf
rm -rf /etc/init.d/mysqld

cp /root/my.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld
chmod a+x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
chown mysql.mysql -R ${mysql_logdir}
chown mysql.mysql -R ${mysql_datadir}
${mysql_dir}/scripts/mysql_install_db --user=mysql --basedir=${mysql_dir} --datadir=${mysql_datadir}
systemctl start mysqld
systemctl enable mysqld
echo 'export PATH=$PATH:'${mysql_dir}'/bin' >> /etc/profile
source "/etc/profile"
${mysql_dir}/bin/mysql -e "grant all privileges on *.* to root@'%' identified by '$mysql_passwd' with grant option;"
${mysql_dir}/bin/mysql -e "flush privileges;"
${mysql_dir}/bin/mysql -e "delete from mysql.user where password='';"
systemctl restart mysqld
echo "mysql install success!"