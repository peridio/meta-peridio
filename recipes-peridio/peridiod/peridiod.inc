SUMMARY = "Peridio Agent Recipe"
DESCRIPTION = "Linux agent for interfacing with peridio.com"
SECTION = "support"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1382e2b09353b0c5786ffa472a8fcf36"

PTEST_ENABLE = "0"

S = "${WORKDIR}/git"

SRC_URI = " \
  git://github.com/peridio/peridiod.git;protocol=https;branch=${SRCBRANCH}; \
  file://peridiod.service \
  file://peridiod.conf \
  file://peridio-cert.pem \
"

inherit mix
inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "peridiod.service"

RDEPENDS:${PN} += "socat wireguard-tools iproute2-ss iptables"

FILES:${PN} += " \
  ${systemd_unitdir}/system/peridiod.service \
  ${systemd_unitdir}/system.conf.d/peridiod.conf \
  ${sysconfdir}/peridiod/peridio-cert.pem \
"

do_compile:prepend() {
  export ERL_EI_LIBDIR="${COMPONENTS_DIR}/${TUNE_PKGARCH}/erlang/usr/lib/erlang/usr/lib"
  export ERL_EI_INCLUDE_DIR="${COMPONENTS_DIR}/${TUNE_PKGARCH}/erlang/usr/lib/erlang/usr/include"
}

do_install:append() {
  install -d ${D}/${systemd_unitdir}/system
  install -d ${D}/${sysconfdir}/peridiod

  archive=$(find ${erlang_release} -name "*.gz")
  bbnote "Removing archive from release directory: ${archive}"
  rm -f ${archive}

  # systemd
  if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
    install -m 0644 ${WORKDIR}/peridiod.service \
      ${D}/${systemd_unitdir}/system
    install -D -m 644 ${WORKDIR}/peridiod.conf \
      ${D}${systemd_unitdir}/system.conf.d/peridiod.conf
  fi

  # sysvinit
  if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}; then
    install -D -m 644 ${WORKDIR}/peridiod.sh \
      ${D}${sysconfdir}/profile.d/peridiod.sh
  fi

  install -m 0644 ${WORKDIR}/peridio-cert.pem \
    ${D}/${sysconfdir}/peridiod
}
