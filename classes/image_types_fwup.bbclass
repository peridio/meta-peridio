# Pull artifact metadata from default sources
PERIDIO_META_AUTHOR ??= "${MAINTAINER}"
PERIDIO_META_PRODUCT ??= "${DISTRO}"
PERIDIO_META_VERSION ??= "${DISTRO_VERSION}"
PERIDIO_META_DESCRIPTION ??= "${DISTRO_NAME}"
PERIDIO_META_ARCHITECTURE ??= "${TARGET_ARCH}-${ABIEXTENSION}"
PERIDIO_META_PLATFORM ??= "${MACHINE}"

# Pull artifact metadata from default sources
PERIDIO_DISK_DEVPATH ??= "/dev/mmcblk0"
PERIDIO_DISK_BLOCK_SIZE ??= "512"

PERIDIO_UBOOT_ENV_OFFSET ??= "2048"
PERIDIO_UBOOT_ENV_COUNT ??= "256"

PERIDIO_BOOTFS_TYPE ??= "fat"
PERIDIO_BOOTFS_OFFSET_BLOCKS ??= "4096"
PERIDIO_BOOTFS_SIZE_MB ??= "16"

PERIDIO_ROOTFS_TYPE ??= "squashfs"
PERIDIO_ROOTFS_OFFSET_BLOCKS ??= "65536"
PERIDIO_ROOTFS_SIZE_MB ??= "256"

PERIDIO_DATAFS_TYPE ??= "f2fs"
PERIDIO_DATAFS_OFFSET_BLOCKS ??= "1310720"
PERIDIO_DATAFS_SIZE_MB ??= "512"

PERIDIO_BOOT_PART_DEVPATH ??= "${PERIDIO_DISK_DEVPATH}p1"
PERIDIO_BOOT_PART_TYPE ??= "${PERIDIO_BOOTFS_TYPE}"

PERIDIO_ROOTFS_A_PART_DEVPATH ??= "${PERIDIO_DISK_DEVPATH}p2"
PERIDIO_ROOTFS_A_PART_TYPE ??= "${PERIDIO_ROOTFS_TYPE}"
PERIDIO_ROOTFS_A_PART_OFFSET_BLOCKS ??= "${PERIDIO_ROOTFS_OFFSET_BLOCKS}"

PERIDIO_ROOTFS_B_PART_DEVPATH ??= "${PERIDIO_DISK_DEVPATH}p3"
PERIDIO_ROOTFS_B_PART_TYPE ??= "${PERIDIO_ROOTFS_TYPE}"

PERIDIO_DATAFS_PART_DEVPATH ??= "${PERIDIO_DISK_DEVPATH}p4"
PERIDIO_DATAFS_PART_TYPE ??= "${PERIDIO_DATAFS_TYPE}"
PERIDIO_DATAFS_PART_MOUNTPOINT ??= "/data"

PERIDIO_ROOTFS_FILE ??= "${IMAGE_NAME}.rootfs.${PERIDIO_ROOTFS_TYPE}"
PERIDIO_HOST_ROOTFS_DIR ??= "${IMGDEPLOYDIR}"
PERIDIO_HOST_IMAGE_DIR ??= "${DEPLOY_DIR_IMAGE}"

FWUP_OUTPUT_NAME ??= "${IMAGE_BASENAME}-${MACHINE}"
FWUP_IMG_TASK ??= "complete"

FWUP_VARS ?= " \
  PERIDIO_META_AUTHOR \
  PERIDIO_META_PRODUCT \
  PERIDIO_META_VERSION \
  PERIDIO_META_DESCRIPTION \
  PERIDIO_META_ARCHITECTURE \
  PERIDIO_META_PLATFORM \
  PERIDIO_DISK_DEVPATH \
  PERIDIO_DISK_BLOCK_SIZE \
  PERIDIO_UBOOT_ENV_OFFSET \
  PERIDIO_UBOOT_ENV_COUNT \
  PERIDIO_BOOTFS_TYPE \
  PERIDIO_BOOTFS_OFFSET_BLOCKS \
  PERIDIO_BOOTFS_SIZE_MB \
  PERIDIO_ROOTFS_TYPE \
  PERIDIO_ROOTFS_OFFSET_BLOCKS \
  PERIDIO_ROOTFS_SIZE_MB \
  PERIDIO_DATAFS_TYPE \
  PERIDIO_DATAFS_OFFSET_BLOCKS \
  PERIDIO_DATAFS_SIZE_MB \
  PERIDIO_BOOT_PART_DEVPATH \
  PERIDIO_BOOT_PART_TYPE \
  PERIDIO_ROOTFS_A_PART_DEVPATH \
  PERIDIO_ROOTFS_A_PART_TYPE \
  PERIDIO_ROOTFS_A_PART_OFFSET_BLOCKS \
  PERIDIO_ROOTFS_B_PART_DEVPATH \
  PERIDIO_ROOTFS_B_PART_TYPE \
  PERIDIO_ROOTFS_B_PART_OFFSET_BLOCKS \
  PERIDIO_DATAFS_PART_DEVPATH \
  PERIDIO_DATAFS_PART_TYPE \
  PERIDIO_DATAFS_PART_MOUNTPOINT \
  PERIDIO_ROOTFS_FILE \
  PERIDIO_HOST_ROOTFS_DIR \
  PERIDIO_HOST_IMAGE_DIR \
  PERIDIO_PRIVATE_KEY \
  PERIDIO_CERTIFICATE \
  FWUP_OUTPUT_NAME \
  FWUP_IMG_TASK \
  MACHINE \
"

FWUP_EXTRA_VARS ?= ""

FWUP_FILE ??= "${MACHINE}.fwup.conf"
FWUP_SEARCH_PATH ?= "${@':'.join('%s/conf/peridio' % p for p in '${BBPATH}'.split(':'))}"
FWUP_FILE_FULL_PATH = "${@fwup_search(d.getVar('FWUP_FILE'), d.getVar('FWUP_SEARCH_PATH')) or ''}"

def fwup_search(f, search_path):
    if os.path.isabs(f):
        if os.path.exists(f):
            return f
    else:
        searched = bb.utils.which(search_path, f)
        if searched:
            return searched

IMAGE_CMD:fwup () {
  set -a
  . "${IMGDEPLOYDIR}/${IMAGE_BASENAME}.fwup.env"
  fwup -c -f "${IMGDEPLOYDIR}/${IMAGE_BASENAME}.fwup.conf" -o "${IMGDEPLOYDIR}/${FWUP_OUTPUT_NAME}.fw"
  set +a
}
do_image_fwup[vardepsexclude] = "FWUP_FILE_FULL_PATH TOPDIR"

IMAGE_CMD:fwup-img () {
  set -a
  . "${IMGDEPLOYDIR}/${IMAGE_BASENAME}.fwup.env"
  fwup -c -f "${IMGDEPLOYDIR}/${IMAGE_BASENAME}.fwup.conf" -o "${IMGDEPLOYDIR}/${FWUP_OUTPUT_NAME}.fw"
  fwup -a -t "${FWUP_IMG_TASK}" \
  -i "${IMGDEPLOYDIR}/${FWUP_OUTPUT_NAME}.fw" \
  -d "${IMGDEPLOYDIR}/${FWUP_OUTPUT_NAME}.img"
  set +a
}
do_image_fwup-img[vardepsexclude] = "FWUP_FILE_FULL_PATH TOPDIR"

USING_FWUP = "${@bb.utils.contains_any('IMAGE_FSTYPES', 'fwup fwup-img', 1, '', d)}"
FWUP_FILE_CHECKSUM = "${@'${FWUP_FILE_FULL_PATH}:%s' % os.path.exists('${FWUP_FILE_FULL_PATH}') if '${USING_FWUP}' else ''}"
do_image_fwup[file-checksums] += "${FWUP_FILE_CHECKSUM}"
do_image_fwup_img[file-checksums] += "${FWUP_FILE_CHECKSUM}"
do_write_fwup_conf[file-checksums] += "${FWUP_FILE_CHECKSUM}"

# We ensure all artfacts are deployed (e.g virtual/bootloader)
do_image_fwup[recrdeptask] += "do_deploy"
do_image_fwup_img[recrdeptask] += "do_deploy"
do_image_fwup[deptask] += "do_image_complete"
do_image_fwup_img[deptask] += "do_image_complete"
do_image_fwup_img[deptask] += "do_image_fwup"

do_image_fwup[depends] += "${@' '.join('%s-native:do_populate_sysroot' % r for r in ('parted', 'gptfdisk', 'dosfstools', 'mtools'))}"
do_image_fwup_img[depends] += "${@' '.join('%s-native:do_populate_sysroot' % r for r in ('parted', 'gptfdisk', 'dosfstools', 'mtools'))}"
do_image_fwup_img[depends] += "${IMAGE_BASENAME}:do_image_fwup"

FWUP_FILE_DEPENDS = "fwup-native syslinux-native bmap-tools-native cdrtools-native btrfs-tools-native squashfs-tools-native e2fsprogs-native"
DEPENDS += "${@ '${FWUP_FILE_DEPENDS}' if d.getVar('USING_FWUP') else '' }"

python do_write_fwup_conf () {
    fwup_file = d.getVar('FWUP_FILE_FULL_PATH')
    depdir = d.getVar('IMGDEPLOYDIR')
    basename = d.getVar('IMAGE_BASENAME')
    bb.utils.copyfile(fwup_file, "%s/%s" % (depdir, basename + '.fwup.conf'))
}

addtask do_write_fwup_conf after do_image before do_image_fwup

#
# Write environment variables used by fwup
# to tmp/sysroots/<machine>/imgdata/<image>.fwup.env
#
python do_rootfs_fwup_env () {
    key_file = d.getVar('PERIDIO_PRIVATE_KEY_FILE')
    if key_file and os.path.isfile(key_file):
        f = open(key_file, 'r')
        key = f.read()
        d.setVar('PERIDIO_PRIVATE_KEY', key)

    cert_file = d.getVar('PERIDIO_CERTIFICATE_FILE')
    if cert_file and os.path.isfile(cert_file):
        f = open(cert_file, 'r')
        cert = f.read()
        d.setVar('PERIDIO_CERTIFICATE', cert)

    fwupvars = d.getVar('FWUP_VARS') + d.getVar('FWUP_EXTRA_VARS')

    if not fwupvars:
        return

    stdir = d.getVar('STAGING_DIR')
    outdir = os.path.join(stdir, d.getVar('MACHINE'), 'imgdata')
    bb.utils.mkdirhier(outdir)
    basename = d.getVar('IMAGE_BASENAME')
    with open(os.path.join(outdir, basename) + '.fwup.env', 'w') as envf:
        for var in fwupvars.split():
            value = d.getVar(var)
            if value:
                envf.write('%s="%s"\n' % (var, value.strip()))
    envf.close()
    # Copy fwup.env file to deploy directory for later use with stand alone fwup
    depdir = d.getVar('IMGDEPLOYDIR')
    bb.utils.copyfile(os.path.join(outdir, basename) + '.fwup.env', os.path.join(depdir, basename) + '.fwup.env')
}

addtask do_rootfs_fwup_env after do_image before do_image_fwup
addtask do_rootfs_fwup_env after do_image before do_image_fwup_img
do_rootfs_fwup_env[vardeps] += "${FWUP_VARS} ${FWUP_EXTRA_VARS}"
