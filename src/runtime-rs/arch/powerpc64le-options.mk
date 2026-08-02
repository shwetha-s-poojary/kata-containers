# Copyright (c) 2019-2022 Alibaba Cloud
# Copyright (c) 2019-2022 Ant Group
#
# SPDX-License-Identifier: Apache-2.0
#

MACHINETYPE := pseries
KERNELPARAMS := cgroup_no_v1=all systemd.unified_cgroup_hierarchy=1
# https://www.qemu.org/docs/master/specs/ppc-spapr-xive.html#xive-for-spapr-pseries-machines
MACHINEACCELERATORS := "ic-mode=xics,cap-cfpc=broken,cap-sbbc=broken,cap-ibs=broken,cap-large-decr=off,cap-ccf-assist=off"
CPUFEATURES :=

QEMUCMD := qemu-system-ppc64
