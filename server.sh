#!/usr/bin/env bash

# 同步时间
yum install -y ntpdate
ntpdate 1.cn.pool.ntp.org
