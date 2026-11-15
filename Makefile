CLANG ?= clang
LLD ?= ld.lld
TARGET ?= aarch64-none-elf
BUILD_DIR ?= build/bootloader/stage0

COMMON_FLAGS := --target=$(TARGET) -ffreestanding -fno-builtin -fno-stack-protector -nostdlib -O2 -Wall -Wextra -Werror

.PHONY: all bootloader stage0-probe clean

all: bootloader

bootloader: $(BUILD_DIR)/entry.o $(BUILD_DIR)/stage0.o

# This is only a post-m1n1 execution proof; it does not satisfy the independent
# bootloader goal. See docs/BOOT_HANDOFF_CONTRACT.md before using the image.
stage0-probe: $(BUILD_DIR)/aetheros-n104-handoff-probe.Image.gz

$(BUILD_DIR)/n104_handoff_probe.o: bootloader/stage0/n104_handoff_probe.S | $(BUILD_DIR)
	$(CLANG) --target=$(TARGET) -c $< -o $@

$(BUILD_DIR)/aetheros-n104-handoff-probe.Image: $(BUILD_DIR)/n104_handoff_probe.o
	$(LLD) --image-base=0 -Ttext=0 --oformat=binary -o $@ $<
	@size=$$(wc -c < "$@"); if [ "$$size" -gt 4096 ]; then echo "probe exceeds one page ($$size bytes)" >&2; exit 1; fi
	truncate -s 4096 "$@"

$(BUILD_DIR)/aetheros-n104-handoff-probe.Image.gz: $(BUILD_DIR)/aetheros-n104-handoff-probe.Image
	gzip -n -9 -c $< > $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/entry.o: bootloader/stage0/entry.S | $(BUILD_DIR)
	$(CLANG) $(COMMON_FLAGS) -c $< -o $@

$(BUILD_DIR)/stage0.o: bootloader/stage0/stage0.c | $(BUILD_DIR)
	$(CLANG) $(COMMON_FLAGS) -std=c11 -c $< -o $@

clean:
	rm -rf build
