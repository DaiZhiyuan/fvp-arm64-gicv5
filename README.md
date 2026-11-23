# FVP ARM64 GICv5 Development & Exploration Environment

This repository provides a ready-to-run, pre-compiled evaluation environment for exploring the next-generation **ARM GICv5** interrupt controller architecture. 

It integrates a bootable Linux kernel carrying the GICv5 host driver patchset, custom TF-A firmware, Device Tree configurations, and boot scripts designed to run on the ARM Fixed Virtual Platform (FVP).

## Key Features

* **Base Model**: Target against `FVP_Base_RevC_AEMvA_GICv5`.
* **Linux Kernel**: mainline **`linux-7.4-rc4`** with native GICv5 support (host driver and KVM vGICv5) (`linux/Image`).
* **TF-A Firmware**: Integrated Trusted Firmware-A with native GICv5 driver support (`tf-a/bl1.bin`, `tf-a/fip.bin`).
* **Device Tree & Config**: Hardware configuration via `dts/fvp-base-gicv5.dts` and `conf/gicv5.yaml`.
* **Out-of-the-Box Execution**: Pre-compiled binaries managed via Git LFS for rapid prototyping without toolchain setup.

## Repository Structure

```text
.
├── conf/
│   └── gicv5.yaml              # GICv5 model configuration specs
├── dts/
│   └── fvp-base-gicv5.dts      # Device tree source for GICv5 FVP
├── linux/
│   └── Image                   # Pre-built ARM64 Linux kernel image
├── rootfs/
│   └── rootfs.ext2             # Root filesystem image
├── tf-a/
│   ├── bl1.bin                 # TF-A Bootloader Level 1
│   └── fip.bin                 # Firmware Image Package (BL2, BL31, BL33)
├── README.md                   # Project documentation
└── run_fvp.sh                  # Main launcher script for FVP

```

## Quick Start

### Prerequisites

1. Install **ARM Fixed Virtual Platform** (`FVP_Base_RevC_AEMvA_GICv5`). Ensure the model binary is available in your `$PATH`.
2. Ensure `git-lfs` is installed to fetch pre-compiled binaries:
```bash
git lfs install
git clone https://github.com/DaiZhiyuan/fvp-arm64-gicv5.git
cd fvp-arm64-gicv5

```

### Running the Environment

Run the launcher script directly:

```bash
chmod +x run_fvp.sh
./run_fvp.sh

```

## Building TF-A Firmware (Optional)

> **Note**: Pre-compiled firmware binaries (`tf-a/bl1.bin` and `tf-a/fip.bin`) are already included in this repository. You can skip this step unless you wish to modify or rebuild Trusted Firmware-A from source.

To rebuild TF-A with GICv5 support using `dts/fvp-base-gicv5.dts`, use the following build command:

```bash
make CROSS_COMPILE=aarch64-none-elf- \
     PLAT=fvp \
     DEBUG=1 \
     CTX_INCLUDE_AARCH32_REGS=0 \
     FVP_USE_GIC_DRIVER=FVP_GICV5 \
     ARM_LINUX_KERNEL_AS_BL33=1 \
     PRELOADED_BL33_BASE=0x84000000 \
     FVP_HW_CONFIG_DTS="fdts/fvp-base-gicv5.dts" \
     all fip

```

## Verifying GICv5 in Linux

Once booted into the guest shell, inspect kernel boot logs and interrupt topology:

```bash
# Check GICv5 initialization log

CPU features: detected: GICv5 CPU interface
GICv5 IRS: irs@2f1a0000 detected SPI range [0-255]
Root IRQ handler: gicv5_handle_irq
GICv5 ITS: ITS its-controller@2f120000 enabled using 2-level device table device_id_bits 20

# Inspect interrupt chip status

           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7
 68:          0          0          0          0          0          0          0          0 GICv5-PPI  30 Level     kvm guest ptimer
 69:          0          0          0          0          0          0          0          0 GICv5-PPI  27 Level     kvm guest vtimer
 70:       3977       7224      14377      39382       9160        333        584       1422 GICv5-PPI  26 Level     arch_timer
 71:          0          0          0          0          0          0          0          0 GICv5-SPI  26 Level     arch_mem_timer
 72:         42          0          0          0          0          0          0          0 GICv5-SPI   5 Level     uart-pl011
 76:        158          0          0          0          0          0          0          0 ITS-v5-GICv5-IWB-2f000000.interrupt-controller  46 Level     virtio2
 80:          0          0          0          0          0          0          0          0 ITS-v5-pMSI-2b400000.iommu   0 Edge      arm-smmu-v3-evtq
 81:          0          0          0          0          0          0          0          0 ITS-v5-pMSI-2b400000.iommu   1 Edge      arm-smmu-v3-gerror
 82:          0          0          0          0          0          0          0          0 ITS-v5-GICv5-IWB-2f000000.interrupt-controller  42 Level     virtio0
 84:        320          0          0          0          0          0          0          0 ITS-v5-PCI-MSIX-0000:00:1f.0   0 Edge      ahci[0000:00:1f.0]
 85:          0          0          0          0          0          0          0          0 ITS-v5-PCI-MSIX-0000:01:00.0   0 Edge      ahci[0000:01:00.0]
 87:         11          0          0          0          0          0          0          0 GICv5-SPI  12 Level     kmi-pl050
 88:        115          0          0          0          0          0          0          0 GICv5-SPI  13 Level     kmi-pl050
 89:          0          0          0          0          0          0          0          0 GICv5-SPI   4 Level     rtc-pl031
 91:          0          0          0          0          0          0          0          0 GICv5-SPI   9 Level     mmci-pl18x (cmd)
 92:          0          0          0          0          0          0          0          0 GICv5-SPI  10 Level     mmci-pl18x (pio)
 93:          0          0          0          0          0          0          0          0 GICv5-PPI  23 Level     arm-pmu
IPI0:        17         16         30         27         29         17         11          9       Rescheduling interrupts
IPI1:       337        751        639       1076        180        132        317         90       Function call interrupts
IPI2:         0          0          0          0          0          0          0          0       CPU stop interrupts
IPI3:         0          0          0          0          0          0          0          0       CPU stop NMIs
IPI4:         0          0          0          0          0          0          0          0       Timer broadcast interrupts
IPI5:        84          5         12         40          0          3          0          0       IRQ work interrupts
IPI6:         0          0          0          0          0          0          0          0       CPU backtrace interrupts
IPI7:         0          0          0          0          0          0          0          0       KGDB roundup interrupts
Err:          0
```

## KVM vGICv5 Selftest Environment

The environment now ships a kernel with in-kernel KVM vGICv5 support plus the ARM64 KVM selftests, so the vGICv5 virtualization can be exercised directly on the model.

### Changes in this update

* **`linux/Image`**: replaced with **Linux v7.4.0-rc4** (`arch/arm64` `defconfig` + `virt.config`, with `CONFIG_KVM=y` and the GICv5 irqchip; 52-bit VA/PA with LPA2). Built with `aarch64-linux-gnu-gcc` 13.3.0. The in-kernel vGICv5 is part of `CONFIG_KVM` (no separate Kconfig option).
* **`rootfs/rootfs.ext2`**: now carries the KVM selftests under `/opt/kvm-selftests/arm64/` (six GIC-related binaries), built from `tools/testing/selftests/kvm` of the same kernel tree.
* **`run_fvp.sh`**:
  * `-C cluster{0,1}.has_arm_v8-5=1` and `-C cluster{0,1}.has_arm_v8-6=1` — **required for KVM vGICv5 guests**, see root-cause note below.
  * `-C bp.terminal_{0..3}.start_telnet=0` — prevents the model from auto-launching an `xterm` that grabs the UART telnet port (which otherwise blocks scripted access to `terminal_0`).

### Why `has_arm_v8-6` is needed (root-cause note)

KVM v7.4-rc4 has a known bug: `kvm_vcpu_load_fgt()` returns early when the CPU does not implement **FEAT_FGT**, before computing the per-vCPU `ICH_HFGRTR/HFGWTR/HFGITR_EL2` values. Those registers then stay `0`, and since the GICv5 fine-grained trap bits are **negative polarity** (`0` = trap enabled), every guest access to GICv5 CPU-interface system registers traps to EL2; the ones without an in-kernel handler (e.g. `ICC_PPI_PRIORITYR0_EL1`) get an undefined exception injected and the guest dies:

```text
kvm [183]: Unsupported guest access at: 404c24
 { Op0( 3), Op1( 0), CRn(12), CRm(14), Op2( 0), func_write },   # ICC_PPI_PRIORITYR0_EL1
```

On this model FEAT_FGT is gated behind the ARMv8.6 extension bundle (`has_arm_v8-6`), even though `cluster.has_fgt` defaults to `1` — hence both `has_arm_v8-5=1` and `has_arm_v8-6=1`. The equivalent kernel-side fix is upstream: *"KVM: arm64: Decouple computation of the GICv5 trap registers from FEAT_FGT"* (Gustavo Romero, kvmarm).

### Selftest results (run on FVP with this `Image` + `rootfs`)

| Test              | Exit code   | Result | Notes                                                                 |
|-------------------|-------------|--------|-----------------------------------------------------------------------|
| `vgic_v5`         | 0           | PASS   | All 11 subtests pass: address / NR_IRQS / IRS_REGS / IST attrs, userspace PPI attrs, CPU sysreg attrs, sparse vCPU IDs, PPIs, SPIs, LPIs, IST save/restore |
| `no-vgic`         | 0           | PASS   | Runs the vGICv5 part; GICv3 parts skipped                              |
| `vgic_init`       | 4 (`KSFT_SKIP`) | SKIP | Requires vGICv3; the GCIE legacy CPU interface is not detected on this model |
| `vgic_irq`        | 4 (`KSFT_SKIP`) | SKIP | Same (`kvm_supports_vgic_v3()` unmet)                                  |
| `vgic_lpi_stress` | 4 (`KSFT_SKIP`) | SKIP | Same                                                                   |
| `vgic_its_save`   | 4 (`KSFT_SKIP`) | SKIP | Same                                                                   |

Full session log: `dmesg` shows `kvm [1]: GCIE system register CPU interface` at boot, and the tests produce zero `Unsupported guest access` / panic messages.

### Running the selftests

Boot the environment, log in as `root` (no password), then run:

```bash
/opt/kvm-selftests/arm64/vgic_v5
# exit code 0 = pass; 4 = KSFT_SKIP (requirement not met)

ls /opt/kvm-selftests/arm64/
```

## Reference Patches

* ~~Linux Host Driver: `v7_20250703_lpieralisi_arm_gicv5_host_driver_implementation` (Lorenzo Pieralisi)~~ — superseded; GICv5 support (host driver, KVM vGICv5 and selftests) is now in the current kernel, **mainline `linux-7.4-rc4`**.

## License

This repository is distributed under the MIT License. Embedded binaries and patches belong to their respective upstream licenses (GPLv2 for Linux Kernel, BSD-3-Clause for TF-A).

```
