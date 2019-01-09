# Copyright (c) 2018-2019 Tom Hancocks
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

################################################################################

ROOT = $(CURDIR)
BUILD = $(ROOT)/build
SCRIPTS = $(ROOT)/support/scripts
BLOBS = $(ROOT)/support/blobs

################################################################################

SCRIPT.grub-floppy = $(SCRIPTS)/grub-floppy.imgscript
BLOB.grub-floppy = $(BLOBS)/grub-floppy-legacy
SYSRD.files = $(ROOT)/support/sysrd
BUILD.kernel = $(BUILD)/vkernel
BUILD.boot-disk = $(BUILD)/VeracyonOS.img
BUILD.sysrd = $(BUILD)/sysrd
GRUB.menu-cfg = $(ROOT)/support/grub/menu.cfg

DEPENDANCY.vkernel = $(ROOT)/../vkernel

################################################################################

.PHONY: all
all: $(BUILD.boot-disk)

.PHONY: clean
clean:
	-rm -rf $(BUILD)

.PHONY: qemu
qemu: $(BUILD.boot-disk)
	qemu-system-x86_64\ -kernel $(BUILD.kernel) -serial stdio \
		-initrd $(BUILD.sysrd)

.PHONY: bochs
bochs: $(BUILD.boot-disk)


################################################################################

$(BUILD):
	-mkdir -p $@

$(BUILD.kernel): $(BUILD)
	INSTALL_PATH=$< make -C$(DEPENDANCY.vkernel) install

$(BUILD.boot-disk): $(BUILD.kernel) $(BUILD.sysrd)
	cp $(BLOB.grub-floppy) $@
	DISK=$@ KERNEL_PATH=$< KERNEL_NAME=VKERNEL \
	SYSRD_PATH=$(BUILD.sysrd) BOOTCFG_PATH=$(GRUB.menu-cfg) \
	imgtool -s $(SCRIPT.grub-floppy)

$(BUILD.sysrd):
	tar c -f $(BUILD.sysrd) $(SYSRD.files)