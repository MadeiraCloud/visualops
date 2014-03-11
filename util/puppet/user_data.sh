#!/bin/bash

# --------------------------------------------------------------------------#
# Copyright 2012, Peng Zhao (peng@mc2.io)                   	 			#
# --------------------------------------------------------------------------#

yum install -y puppet
#echo "10.150.186.106 puppet.madeiracloud.com" >> /etc/hosts
puppetd --test --server puppet.madeiracloud.com --certname host1.config.monitor.madeiracloud 