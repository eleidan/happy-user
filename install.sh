#!/bin/bash

OK="OK"
DONE="DONE"
DOWNLOADS_PATH=$HOME/install-tmp

function prepare {
  mkdir -p $DOWNLOADS_PATH
  mkdir -p $HOME/forge
}

function exists {
  if [[ -f $1 ]]
  then
    echo $OK
    return 1
  else
    return 0
  fi
}

function check_installed {
  which $1 > /dev/null
  if [[ "$?" -eq "0" ]]
  then
    echo $OK
    return 1
  else
    return 0
  fi
}

function read_lsb_release {
  source /etc/lsb-release
}

function clean_up {
  echo "CLEAN UP" \
    && rm -rf $DOWNLOADS_PATH \
    && echo $DONE
}


################################################################################
# Check if command is issued with proper privileges
if [[ "$(id -u)" -ne "0" ]]; then
  echo "This script requires root privileges!"
fi


prepare

################################################################################
# BASH
BASH_FILE=$HOME/.bashrc

function check_customizations {
  grep "bash_customizations" $BASH_FILE > /dev/null
  if [[ "$?" -eq "0" ]]; then
    echo $OK
    return 1
  fi
}

echo -n "Bash : " \
  && check_customizations \
  && echo -e "\nif [ -f ~/.bash_customizations ]; then" >> $BASH_FILE \
  && echo "  . ~/.bash_customizations" >> $BASH_FILE \
  && echo "fi" >> $BASH_FILE \
  && echo $DONE


################################################################################
# SSH
echo -n "SSH : " \
  && exists $HOME/.ssh/id_rsa \
  && ssh-keygen -t rsa \
  && echo $DONE



################################################################################
# GIT
function set_aliases {
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global alias.last 'log -1 HEAD'
}

function initial_setup {
  git config --global user.name "John Doe"
  git config --global user.email johndoe@example.com
}

echo -n "Git : " \
  && set_aliases \
  && initial_setup \
  && echo $DONE



################################################################################
# ATOM
# NOTE: depends on Git
ATOM_PKG=$DOWNLOADS_PATH/atom.deb
echo -n "Atom : " \
  && check_installed "atom" \
  && wget -c -O $ATOM_PKG https://atom.io/download/deb \
  && sudo dpkg -i $ATOM_PKG \
  && rm $ATOM_PKG



################################################################################
# DOCKER
function install_virtual_kernel_package {
  case $DISTRIB_DESCRIPTION in
    "Ubuntu 16.04.2 LTS" | "Ubuntu 16.04.3 LTS" )
      sudo apt-get install linux-image-extra-virtual-hwe-16.04
      ;;
    * )
      sudo apt-get install linux-image-extra-virtual
      ;;
  esac
}

function prerequisites {
  read_lsb_release
  case $DISTRIB_RELEASE in
    "16.04" )
      echo "Installing prerequisites for Ubuntu 16.04:" \
        && echo "Adding GPG key" \
        && sudo apt-key adv \
          --keyserver hkp://ha.pool.sks-keyservers.net:80 \
          --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
        && echo "$DONE" \
        && REPO="deb https://apt.dockerproject.org/repo ubuntu-xenial main" \
        && echo -n "Adding repository $REPO" \
        && echo $REPO | sudo tee /etc/apt/sources.list.d/docker.list \
        && echo "$DONE" \
        && echo -n "Installing new packages" \
        && install_virtual_kernel_package \
        && sudo apt-get install python-pip \
        && echo "$DONE" \
      echo "Preparing file system for docker-engine:" \
        && DOCKER_DIR=/home/.docker \
        && echo "Creating directory $HOME/.docker" \
        && sudo mkdir $DOCKER_DIR \
        && echo "$DONE" \
        && echo "Creating symlink to $DOCKER_DIR at /var/lib/docker" \
        && sudo ln -s $DOCKER_DIR /var/lib/docker \
        && echo "$DONE" \
      echo "Installing latest version of docker-engine:" \
        && echo -n "Updating registry" \
        && sudo apt-get update > /dev/null \
        && echo "$DONE" \
        && echo -n "Installing package" \
        && sudo apt-get install -y docker-engine \
        && echo "$DONE" \
      echo "Adding current user to the docker group:" \
        && sudo usermod -aG docker $USER \
        && echo "$DONE" \
      return 0
      ;;
  esac

  echo "No idea how to provide Docker for Ubuntu $DISTRIB_RELEASE."
  return 1
}

echo "Docker" \
  && check_installed "docker" \
  && prerequisites \
  && echo $DONE



################################################################################
# HTOP
echo "Docker Compose" \
  && check_installed "docker-compose" \
  && sudo pip install docker-compose \
  && echo $DONE
  # && sudo curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \



################################################################################
# HTOP
echo "HTOP" \
  && check_installed "htop" \
  && sudo apt-get install -y htop \
  && echo $DONE

################################################################################
# Tree
echo "TREE" \
  && check_installed "tree" \
  && sudo apt-get install -y tree \
  && echo $DONE



################################################################################
# Pygments
echo "Pygments" \
  && check_installed "pygmentize" \
  && sudo apt install python-pygments \
  && echo $DONE

################################################################################
# Neovim
echo "Neovim" \
  && check_installed "nvim" \
  && sudo add-apt-repository ppa:neovim-ppa/stable \
  && sudo apt-get update \
  && sudo apt install neovim \
  && echo $DONE

################################################################################
# i3wm
echo "i3wm" \
  && check_installed "i3" \
  && sudo apt install i3 \
  && echo $DONE


###############################################################################
# i3blocks
echo "i3blocks" \
  && check_installed "i3blocks" \
  && sudo apt install i3blocks \
  && echo $DONE

KEYBOARD_LAYOUT_FETCHER="$DOWNLOADS_PATH/klf"
echo -n "Keyboard layout fetcher for i3blocks:" \
  && git clone git@github.com:eleidan/keyboard-layout-fetcher.git $KEYBOARD_LAYOUT_FETCHER \
  && sudo cp -i $KEYBOARD_LAYOUT_FETCHER/keyboard /usr/share/i3blocks/keyboard \
  && sudo chmod a+x /usr/share/i3blocks/keyboard


################################################################################
# cmus
echo "cmus" \
  && check_installed "cmus" \
  && sudo apt install cmus \
  && echo $DONE


################################################################################
# scrot, for screenshots
TARGET="scrot"
echo ${TARGET} \
  && check_installed ${TARGET} \
  && sudo apt install ${TARGET} \
  && mkdir -p $HOME/Pictures/screenshots \
  && echo $DONE


################################################################################
# dotfiles
DOTFILES="$DOWNLOADS_PATH/dotfiles"

echo -n "Checkout dotfiles repo: " \
  && git clone git@github.com:eleidan/dotfiles.git $DOTFILES

I3WM="$HOME/.config/i3"
echo -n "i3wm configs : " \
  && mkdir -p $I3WM \
  && cp -i $DOTFILES/.config/i3/config $I3WM/config

I3STATUS="$HOME/.config/i3status"
echo -n "i3status configs : " \
  && mkdir -p $I3STATUS \
  && cp -i $DOTFILES/.config/i3status/config $I3STATUS/config

I3BLOCKS="$HOME/.config/i3blocks"
echo -n "i3blocks configs : " \
  && mkdir -p $I3BLOCKS \
  && cp -i $DOTFILES/.config/i3blocks/config $I3BLOCKS/config


################################################################################
# Force GIT config update
git config --global --edit

clean_up
# https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
