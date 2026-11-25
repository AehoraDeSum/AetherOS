/* SPDX-License-Identifier: GPL-2.0-only
 *
 * AetherOS-owned, RAM-only handoff probe for the iPhone 11 / N104AP.
 *
 * This is deliberately a Linux arm64 Image-compatible payload because the
 * current Cascadia test path has m1n1 load that slot. It is not an independent
 * bootloader and does not replace iBSS, iBoot, or m1n1. At entry it requires
 * the observed m1n1 -> Linux state: EL1, MMU off, x0 = DTB physical address.
 * It uses no stack and touches only the known iBoot framebuffer, painting it
 * green before waiting forever. A green panel is the visible stage-entry
 * marker; there is no Linux initramfs or USB shell in this probe image.
 *
 * N104 simpledrm framebuffer: 0x8fa298000, 828x1792, stride 0xd00,
 * x2r10g10b10, length 0x5b0000. Proven by the device's current reference boot.
 */
	.section .text.boot, "ax"
	.global _start
	.type _start, %function
_start:
	b	aetheros_probe_entry		/* Image code0 */
	.long	0				/* code1 */
	.quad	0				/* text_offset */
	.quad	0x1000			/* image_size (padded probe size) */
	.quad	0			/* flags */
	.quad	0			/* reserved */
	.quad	0			/* reserved */
	.quad	0			/* reserved */
	.ascii	"ARM"
	.byte	0x64				/* arm64 Image magic at 0x38 */
	.long	0				/* PE header offset */

	.balign 64
	aetheros_probe_entry:
	/* x1 = framebuffer base 0x8fa298000 */
	movz	x1, #0x8000
	movk	x1, #0xfa29, lsl #16
	movk	x1, #0x0008, lsl #32
	/* x2 = framebuffer bytes / 4 = 0x16c000 pixels */
	movz	x2, #0xc000
	movk	x2, #0x0016, lsl #16
	/* x4 = opaque green in x2r10g10b10: 0x000ffc00 */
	movz	w4, #0xfc00
	movk	w4, #0x000f, lsl #16
1:
	str	w4, [x1], #4
	subs	x2, x2, #1
	b.ne	1b
	dsb	sy
2:
	wfe
	b	2b
	.size _start, . - _start
