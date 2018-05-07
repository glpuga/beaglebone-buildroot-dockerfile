#
# Starting image from LTS Ubuntu 16.04
FROM ubuntu:16.04

#
# Update the packaged database, before installinga few packages.
# Also install apt-utils, just to avoid warnings down the road about
# apt-utils not being intalled.
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

#
# Install xz-utils and gzip to untar the cross-compilations tools.
# The enviroment variable tells ubuntu that apt-utils is present in the
# system. This is a quirk on the Ubuntu:16.04 official image.
# Install build-essential to get make and other stuff
# Install libncurses5-dev to enable make menuconfig.
# install wget, required by buildroot
# Install other smaller utilities required by buildroot.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install xz-utils gzip build-essential binutils libncurses5-dev wget
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget cpio python bc file rsync unzip

#
# Build environment variables
ENV ARCH           arm
ENV CROSS_COMPILE  arm-linux-gnueabihf-
ENV O              /root/storedstate/output

#
# Buildroot source file data
ENV BUILDROOT_FILE_PREFIX "buildroot-2018.02.2"
ENV BUILDROOT_FILE_NAME   $BUILDROOT_FILE_PREFIX".tar.gz"
ENV BUILDROOT_DWLD_ADDR   "https://buildroot.org/downloads/"$BUILDROOT_FILE_NAME

#
# Toolchain binaries file data
ENV TOOLCHAIN_FILE_PREFIX "gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf"
ENV TOOLCHAIN_FILE_NAME   $TOOLCHAIN_FILE_PREFIX".tar.xz"
ENV TOOLCHAIN_DWLD_ADDR   "https://releases.linaro.org/components/toolchain/binaries/latest/arm-linux-gnueabihf/"$TOOLCHAIN_FILE_NAME

#
# Toolchain path
ENV CROSS_TOOLCHAIN_PATH  /opt/linaro-arm-linux-gnueabihf

#
# Select the buildroot configuration file.
ENV BUILDROOT_CONFIG_FILE buildroot_beaglebone_config

#
# Work folder where to build buildroot
ENV BUILDROOT_FOLDER      /root/buildrootsource
ENV STORED_STATE_PATH     /root/storedstate

#
# Setup the build environment
WORKDIR /root

RUN wget -nv $BUILDROOT_DWLD_ADDR \
    && wget -nv $TOOLCHAIN_DWLD_ADDR

RUN mkdir $STORED_STATE_PATH \
    && mkdir $STORED_STATE_PATH/dl \
    && mkdir $STORED_STATE_PATH/output \
    && tar xvf $BUILDROOT_FILE_NAME \
    && mv $BUILDROOT_FILE_PREFIX $BUILDROOT_FOLDER \
    && rm $BUILDROOT_FILE_NAME \
    && tar xvf $TOOLCHAIN_FILE_NAME \
    && mv $TOOLCHAIN_FILE_PREFIX $CROSS_TOOLCHAIN_PATH \
    && rm $TOOLCHAIN_FILE_NAME \
    && echo "export PATH=$PATH:"$CROSS_TOOLCHAIN_PATH"/bin" >> .bashrc \
    && echo "alias make=\"make O="$STORED_STATE_PATH"\"/output" >> .bashrc

COPY files/entrypoint.sh .
COPY files/$BUILDROOT_CONFIG_FILE .config

WORKDIR $BUILDROOT_FOLDER

RUN make distclean

#
# Entrypoint will call make, or you can call a bash shell.

ENTRYPOINT ["/root/entrypoint.sh"]
