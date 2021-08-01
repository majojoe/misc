#!/bin/bash -e


TEMP_DIR=$(mktemp -d)

trap onexit EXIT

#trap handler 
onexit() { 
        # delete temp dir on exit
        if [ -d "${TEMP_DIR}" ]; then
                rm -rf "${TEMP_DIR}"
        fi
}


if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root in order to join to the given domain. Exiting..."
        exit
fi

# download and install a deb package
# first param: package address to download the deb package from
download_and_install_deb_package () {
        PACKAGE_URL="${1}"
        if [ -d "${TEMP_DIR}" ]; then
                wget "${PACKAGE_URL}" -P "${TEMP_DIR}"
                apt install "${TEMP_DIR}/$(basename "${PACKAGE_URL}")"
        else
                echo " No valid tempdir. Cannot install debian package $(basename "${PACKAGE_URL}"
        fi
}

# add a ppa repository
# first param: ppa repository to add in form LAUNCHPAD-NUTZERNAME/PPA-NAME
add_ppa_repo () {
        PPA_REPO="${1}"
        add-apt-repository -y "ppa:${PPA_REPO}"
}
    
#veracrypt
add_ppa_repo "unit193/encryption"
#unetbootin
add_ppa_repo "gezakovacs/ppa"
#cherrytree
add_ppa_repo "giuspen/ppa"

sudo apt install -y android-tools-adb apt-transport-https avahi-discover build-essential  chromium-browser cmake curl debconf-utils default-jdk digikam docker-compose docker.io domain-join freecad freeglut3-dev gimp gimp-help-de git gnome-keyring grsync htop inkscape  kazam kdiff3 keepass2 kipi-plugins kolourpaint krb5-user krita language-pack-gnome-de libboost-dev libglu1-mesa-dev  links2 maxima mc memtester mesa-common-dev netdiscover net-tools nmap openjdk-8-jdk-headless python3-pip qt5-default qtcreator qtmultimedia5-dev qttools5-dev sbcl   speedometer ssh sweethome3d sweethome3d-furniture-nonfree  texinfo  uuid-dev wireshark cherrytree unetbootin veracrypt

download_and_install_deb_package https://go.skype.com/skypeforlinux-64.deb
download_and_install_deb_package https://www.syntevo.com/downloads/smartgit/smartgit-21_1_0.deb
download_and_install_deb_package https://download.teamviewer.com/download/linux/teamviewer_amd64.deb

#Packages to download manually:
#teams
