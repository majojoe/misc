cmake_minimum_required(VERSION 2.8.11)


install(FILES realmd.conf DESTINATION /etc)
install(FILES krb5.conf.unconfigured DESTINATION /etc)
install(FILES domain_join.sh DESTINATION bin PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)


set(CPACK_PACKAGE_NAME "domain-join")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "meta package that automates domain join for ubuntu systems")
set(CPACK_PACKAGE_VERSION "0.0.17")
set(SYSTEM_ARCH "all")

set(CPACK_DEBIAN_PACKAGE_DEPENDS "realmd,sssd,sssd-tools,samba-common,packagekit,samba-common-bin,samba-libs,adcli,cifs-utils,libpam-mount,libpam-ccreds,findutils,dialog,libpam-sss,coreutils,xmlstarlet")
set(CPACK_GENERATOR "DEB")
set(PACKAGE_OS "linux")
set(CPACK_SYSTEM_NAME "${PACKAGE_OS}-amd64")
set(SYSTEM_ARCH "amd64")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Johannes Maier <maier_jo@gmx.de>")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/postinst;${CMAKE_CURRENT_SOURCE_DIR}/prerm;${CMAKE_CURRENT_SOURCE_DIR}/preinst;${CMAKE_CURRENT_SOURCE_DIR}/postrm")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_DEBIAN_REVISON}${CPACK_SYSTEM_NAME}")


include(CPack)


