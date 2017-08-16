#!/bin/sh

TODO_LIST="vim-tiny thunderbird"
echo "Uninstall:\n\t$TODO_LIST"
sudo apt-get purge $TODO_LIST

echo "Disable apport reporting"
sudo sed -i -e 's/enabled=1/enabled=0/g' /etc/default/apport
