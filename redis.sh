#!/usr/bin/bash

source /etc/profile
source ./include.sh

server_dir=/home/srv
redis=redis-3.2.9
install_dir=${server_dir}/install

# download redis
redis_file_path=${install_dir}/${redis}.tgz
download ${redis_file_path} http://download.redis.io/releases/${redis}.tar.gz
redis_folder_path=${install_dir}/${redis}
if [ ! -d ${redis_folder_path} ]; then
    tar -zxvf ${redis_file_path} -C ${install_dir}
else
    println "${redis} source exist"
fi

# install redis
redis_server=/usr/local/bin/redis-server
if [ ! -f ${redis_server} ]; then
    cd ${install_dir}/${redis}
    make clean && make && make install
fi
redis_conf=/etc/redis/6379.conf
if [ ! -f ${redis_conf} ]; then
    buildir `dirname ${redis_conf}`
    cp ${install_dir}/${redis}/redis.conf ${redis_conf}
else
    println "${redis} has installed!"
fi

redis_init_script=/etc/init.d/redis
if [ ! -f ${redis_init_script} ]; then
    # copy config file
    cp ${install_dir}/${redis}/utils/redis_init_script ${redis_init_script}

    # run as system service
    iinsert 1 "# chkconfig: 2345 80 90" /etc/init.d/redis
    chkconfig --add redis
    systemctl start redis
    systemctl enable redis
fi


redis_ext=redis-3.1.2
redis_ext_file=${install_dir}/${redis_ext}.tgz
download ${redis_ext_file} http://pecl.php.net/get/${redis_ext}.tgz
redis_ext_path=${install_dir}/redis_ext
if [ ! -d ${redis_ext_path} ]; then
    tar -zxvf ${redis_ext_file} -C ${install_dir}
    cd ${install_dir}/${redis_ext}
    phpize
    ./configure
    make && make install
else
    println "${redis} source exist"
fi
# http://pecl.php.net/get/redis-3.1.2.tgz