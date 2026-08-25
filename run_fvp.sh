#!/bin/bash

TFA=./tf-a
ROOTFS=./rootfs
CONF=./conf
LINUX=./linux

FVP_Base_RevC-2xAEMvA_GICV5	\
		-C pctl.startup=0.0.0.0 \
		-C bp.virtio_rng.enabled=1 \
		-C cluster0.NUM_CORES=4 \
		-C cluster0.has_delayed_sysreg=0 \
		-C cluster1.NUM_CORES=4 \
		-C cluster1.has_delayed_sysreg=0 \
		-C cache_state_modelled=0 \
		-C bp.secure_memory=0 \
		-C bp.pl011_uart0.uart_enable=1 \
		-C bp.pl011_uart0.untimed_fifos=1 \
		-C bp.pl011_uart0.unbuffered_output=1 \
		-C bp.secureflashloader.fname=$TFA/bl1.bin \
		-C bp.flashloader0.fname=$TFA/fip.bin \
		--data cluster0.cpu0=$LINUX/Image@0x84000000 \
		-C pci.pcie_rc.ahci0.ahci.image_path=$ROOTFS/rootfs.ext2 \
		-C gicv5_config_file=$CONF/gicv5.yaml
