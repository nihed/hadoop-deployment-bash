#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright Clairvoyant 2016

# Function to discover basic OS details.
discover_os () {
  if command -v lsb_release >/dev/null; then
    # CentOS, Ubuntu
    OS=`lsb_release -is`
    # 7.2.1511, 14.04
    OSVER=`lsb_release -rs`
    # 7, 14
    OSREL=`echo $OSVER | awk -F. '{print $1}'`
    # trusty, wheezy, Final
    OSNAME=`lsb_release -cs`
  else
    if [ -f /etc/redhat-release ]; then
      if [ -f /etc/centos-release ]; then
        OS=CentOS
      else
        OS=RedHat
      fi
      OSVER=`rpm -qf /etc/redhat-release --qf="%{VERSION}.%{RELEASE}\n" | awk -F. '{print $1"."$2}'`
      OSREL=`rpm -qf /etc/redhat-release --qf="%{VERSION}\n"`
    fi
  fi
}

# Check to see if we are on a supported OS.
discover_os
if [ "$OS" != RedHat -a "$OS" != CentOS -a "$OS" != Debian -a "$OS" != Ubuntu ]; then
  echo "ERROR: Unsupported OS."
  exit 3
fi

if [ "$OS" == RedHat -o "$OS" == CentOS ]; then
  yum -y -e1 -d1 install jq ksh
elif [ "$OS" == Debian -o "$OS" == Ubuntu ]; then
  apt-get -y -q install jq ksh
fi

#cp -p {start,stop}_cluster.ksh /usr/local/sbin/
#chown 0:0 /usr/local/sbin/{start,stop}_cluster.ksh
#chmod 700 /usr/local/sbin/{start,stop}_cluster.ksh
install -o root -g root -m 0700 start_cluster.ksh /usr/local/sbin/start_cluster.ksh
install -o root -g root -m 0700 stop_cluster.ksh /usr/local/sbin/stop_cluster.ksh
rm -f /tmp/$$
crontab -l | egrep -v 'stop_cluster.ksh|start_cluster.ksh' >/tmp/$$
echo '00 08 * * * /usr/local/sbin/start_cluster.ksh >/dev/null'>>/tmp/$$
echo '00 18 * * * /usr/local/sbin/stop_cluster.ksh >/dev/null'>>/tmp/$$
crontab /tmp/$$
rm -f /tmp/$$
