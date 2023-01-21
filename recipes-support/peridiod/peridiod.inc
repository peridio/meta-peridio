SUMMARY = "Peridio Agent Recipe"
DESCRIPTION = "Linux agent for interfacing with peridio.com"
SECTION = "support"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1382e2b09353b0c5786ffa472a8fcf36"

S = "${WORKDIR}/git"

SRC_URI = " \
  git://github.com/peridio/peridiod.git;protocol=https;branch=${SRCBRANCH}; \
  file://peridiod.service \
"

inherit mix
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "peridiod.service"

FILES:${PN} += "${systemd_unitdir}/system/peridiod.service"

do_install:append() {
  install -d ${D}/${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/peridiod.service ${D}/${systemd_unitdir}/system
}
