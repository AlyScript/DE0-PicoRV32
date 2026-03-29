ENTRY(_start)

/* INPUT(entry.o, main.o) */
/* OUTPUT(prog.bin) */

/* MEMORY */
/* { */
/*     RAM (rwx) : ORIGIN = 0x0, LENGTH = 32K */
/* } */

SECTIONS
{
   . = 0x0;
   .text :
   {
        *(.text)
        . = ALIGN(4);
   } 
   .sbss :
   {
        *(.sbss)
   }
   .bss :
   {
        *(.bss)
        _end = .;
   } 
}
