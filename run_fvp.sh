#!/bin/bash

TFA=./tf-a
ROOTFS=./rootfs
CONF=./conf
LINUX=./linux
FVP=FVP_Base_RevC-2xAEMvA_GICV5
TRACE_FILE=${GICV5_TRACE_FILE:-./gicv5-irs-commands.log}
TRACE_ARGS=()

if [[ ${1:-} == --trace-on ]]; then
	FVP_BIN=$(command -v "$FVP")
	FVP_ROOT=$(cd "$(dirname "$(readlink -f "$FVP_BIN")")/.." && pwd)
	TRACE_PLUGIN=$FVP_ROOT/plugins/GenericTrace.so
	: > "$TRACE_FILE"
	TRACE_ARGS+=(
		--plugin "$TRACE_PLUGIN"
		-C TRACE.GenericTrace.trace-sources='*.gicv5.irs*.GICV5_IRS_UPSTREAM_COMMAND_RECEIVED,*.gicv5.irs*.GICV5_IRS_DOWNSTREAM_COMMAND'
		-C TRACE.GenericTrace.trace-file="$TRACE_FILE"
		-C TRACE.GenericTrace.simulated-timestamp=1
		-C TRACE.GenericTrace.flush=1
	)
elif [[ $# -gt 0 ]]; then
	printf 'Usage: %s [--trace-on]\n' "$0" >&2
	exit 2
fi

"$FVP" \
		"${TRACE_ARGS[@]}" \
		-C pctl.startup=0.0.0.0 \
		-C bp.virtio_rng.enabled=1 \
		-C cluster0.NUM_CORES=4 \
		-C cluster0.has_arm_v8-5=1 \
		-C cluster0.has_arm_v8-6=1 \
		-C cluster0.has_delayed_sysreg=0 \
		-C cluster1.NUM_CORES=4 \
		-C cluster1.has_arm_v8-5=1 \
		-C cluster1.has_arm_v8-6=1 \
		-C cluster1.has_delayed_sysreg=0 \
		-C cache_state_modelled=0 \
		-C support_virtualization=1 \
		-C bp.secure_memory=0 \
		-C bp.pl011_uart0.uart_enable=1 \
		-C bp.pl011_uart0.untimed_fifos=1 \
		-C bp.pl011_uart0.unbuffered_output=1 \
		-C bp.terminal_0.start_telnet=1 \
		-C bp.terminal_1.start_telnet=1 \
		-C bp.terminal_2.start_telnet=1 \
		-C bp.terminal_3.start_telnet=1 \
		-C bp.secureflashloader.fname=$TFA/bl1.bin \
		-C bp.flashloader0.fname=$TFA/fip.bin \
		--data cluster0.cpu0=$LINUX/Image@0x84000000 \
		-C pci.pcie_rc.ahci0.ahci.image_path=$ROOTFS/rootfs.ext2 \
		-C gicv5_config_file=$CONF/gicv5.yaml
