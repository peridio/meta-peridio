inherit core-image
inherit peridio-image-setup

DEPENDS:append = " fwup-native"

IMAGE_POSTPROCESS_COMMAND += "do_fwup_image_complete; "

do_fwup_image_complete() {
  fwup -c -f ${DEPLOY_DIR_IMAGE}/fwup.conf -o ${IMGDEPLOYDIR}/${MACHINE}.fw
}
