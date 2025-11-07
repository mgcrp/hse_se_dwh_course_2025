#!/bin/bash
set -e

sh /etc/postgresql/init-script/bash/0001-create-replica-user.sh
sh /etc/postgresql/init-script/bash/0002-backup-master.sh
sh /etc/postgresql/init-script/bash/0003-init-slave.sh
