%macro exit 1
    mov rdi, %1
    mov rax, SYS_EXIT
    syscall
%endmacro

STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2

SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_OPEN    equ 2
SYS_CLOSE   equ 3
SYS_STAT    equ 4
SYS_FSTAT   equ 5
SYS_LSTAT   equ 6
SYS_POLL    equ 7
SYS_LSEEK   equ 8
SYS_MMAP    equ 9

SYS_EXIT    equ 60

O_RDONLY    equ 0
O_WRONLY    equ 1
O_RDWR      equ 2

PROT_READ   equ 1
MAP_PRIVATE equ 2