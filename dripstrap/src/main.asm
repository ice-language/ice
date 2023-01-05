%include "linux.inc"
; %include "mem.asm"


[section .data]
    textArgs db "Argument(s): ", 0
    newline db 10,0
    file: db "tests/hello.tu", 0

[section .bss]
    argc resb 8
    argPos resb 8

[section .text]
global _start

_start:
    pop r8
    pop rax

    mov r8, rax
    add r8, 17
    
    mov rsi, textArgs
    mov rdx, 13
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall ; print to stdout

    mov rsi, r8
    mov rdx, 6
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall ; print to stdout

    mov rsi, newline
    mov rdx, 1
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall ; print to stdout

    push rbp
    mov rbp, rsp ; prologue
    


    mov rax, SYS_OPEN ; open file
    mov rsi, O_RDONLY ; read only
    mov rdi, file ; file path
    syscall ; rax = file descriptor (16bit) (fs)

    push rax
    sub rsp, 144 ; 144 byte "buffer" for the fstat struct

    mov rdi, rax ; fs
    mov rsi, rsp ; buffer start 
    mov rax, SYS_FSTAT ; file stats
    syscall ; buffer (takes 144 bytes) = fstat struct

    mov rsi, [rsp+48] ; st_size offset (file length)
    add rsp, 144 ; "free" struct
    mov r8, rdi ; fs, mmap expects that on r8
    xor rdi, rdi
    mov rdx, PROT_READ
    mov r10, MAP_PRIVATE
    xor r9, r9
    mov rax, SYS_MMAP
    syscall ; rax = buffer address

    mov rdx, rsi ; st_size still
    mov rsi, rax
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall ; print to stdout

    pop rax
    mov rsp, rbp ; epilogue
    pop rbp

    exit 69