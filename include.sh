#!/usr/bin/env bash

# 当前目录
CURRENT_DIR=`pwd`

# 转小写
function tolower(){
    echo `tr '[A-Z]' '[a-z]' <<<"$1"`
}

# 转大写
function toupper(){
    echo `tr '[a-z]' '[A-Z]'  <<<"$1"`
}

# 打印
function println(){
    echo -e ${1}
}

# 穿件目录
# @param path 目录路径
function buildir(){
    # 检查父目录
    parentdir=`dirname $1`
    if [ ! -d ${parentdir} ]; then
        echo -e "--LITE--       to make parentdir ${parentdir}"
        buildir ${parentdir}
    fi
    # 创建文件夹
    if [ ! -d $1 ]; then
        echo -e "--LITE--       to make dir ${1}"
        mkdir $1
    else
        echo -e "--LITE--       to make dir ${1}:exist"
    fi
}

# 下载文件
# @param path 下载文件保存路径
# @param url  下载链接
#
function download(){
    buildir `dirname $1`
    if [ ! -f $1 ]; then
        echo -e "file '${1}' begin download";
    #   wget命令不存在于mingw环境中
    #        wget $2 -O $1
        curl -o $1 -L --connect-timeout 100000 --max-time 100000 --retry 100 $2
    else
        echo -e "file '${1}' exist, stop download";
    fi
}

# 拷贝文件或者文件夹
# @param from
# @param to
function copy(){
    from=${1}
    to=${2}
    parentdir=`dirname ${to}`
    buildir ${parentdir}
    cp -R ${from} ${to}
}


function addpath(){
    echo "export PATH=\${PATH}:${1}" >> /etc/profile
    source /etc/profile
}


# replace text in certain line
# @param int $line_number
# @param string $text2replace
# @param string $textfilepath
function line_replace(){
    sed -i "${1}c ${2}" ${3}
}

# insert text into text file
# @param int $line_number
# @param string $text2insert
# @param string $textfilepath
function iinsert(){
    if [ ! -f ${3} ]; then
        touch ${3}
    fi
    sed -i "${1}a ${2}" ${3}
}
# 备份文件到同级目录下
# @param path 待备份文件的路径
function backup(){
    if [ ! -f "${1}.bak" ] ; then
        cp $1 "${1}.bak"
    fi
}




# 提高TCP负载能力
echo 1024 >/proc/sys/net/core/somaxconn

# 虚拟内存配置 2 GB
#mkdir -p /var/cache/swap/
#dd if=/dev/zero of=/var/cache/swap/swap0 bs=1M count=2048
#chmod 0600 /var/cache/swap/swap0
#mkswap /var/cache/swap/swap0
# 下面的操作可能会失败，提示:swapon: Operation not permitted
# 这是OpenVZ架构的VM的限制
#swapon /var/cache/swap/swap0



# 实际上，上边这个脚本只能增加一个可看但不可用的swap而已
#SWAP="${1:-512}"
#NEW="$[SWAP*1024]"; TEMP="${NEW//?/ }"; OLD="${TEMP:1}0"
#umount /proc/meminfo 2> /dev/null
#sed "/^Swap\(Total\|Free\):/s,$OLD,$NEW," /proc/meminfo > /etc/fake_meminfo
#mount --bind /etc/fake_meminfo /proc/meminfo



# 正确给OpenVZ的VPS增加SWAP的做法是登录母鸡：
#copy ${CURRENT_DIR}/repo/openvz.repo /etc/yum.repos.d/openvz.repo
#cd /etc/yum.repos.d
#rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ
#yum update -y
#yum install ovzkernel vzctl vzquota -y
#vzctl set 33 --swappages 0:2048M --save
