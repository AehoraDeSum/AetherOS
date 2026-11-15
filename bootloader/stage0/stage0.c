/*
 * Compile-only scaffold. The target entry state, safe stack, load address,
 * console and hardware initialization are not known yet. Do not run this on
 * the device until BOOTLOADER_RESEARCH.md reaches a compliant go decision.
 */
__attribute__((noreturn))
void stage0_entry(void)
{
    for (;;) {
        __asm__ volatile("wfe" ::: "memory");
    }
}
