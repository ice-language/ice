%include "../../../libcube/include/linux.inc"
%include "errors.asm"

[section .rodata]
    newline db 10
    text0 db "Open File: "
    text0Len equ $ - text0

[section .bss]
    argCount resb 8
    path resb 8 ; ptr ptr char
    argStart resb 8 ; ptr ptr[char]
    ; path and argStart must be derefed 2x
    ; argStart indexing is at the second deref

[section .text]
global _start

extern strlen
extern printc
extern prints
extern printv


_start:
    push rbp
    mov rbp, rsp ; prologue

    ; copy command line argument pointers
    ; init stack looks like this
    ; push thingy <-
    ; argument Count
    ; path
    ; argument 1 <- root compilation file path
    ; argument n
    ; rsp
    ; rbp <- rbp
    mov rax, [rsp - 8]
    dec rax ; dec to treat arguments different from the path
    
    jz _error_file_missing ; no file supplied in cmd args, end
    mov [argCount], rax
    mov rax, rsp
    add rax, 16
    mov [path], rax
    add rax, 8
    mov [argStart], rax
    
    lea rsi, text0
    mov rdx, text0Len
    call prints
   
    mov rsi, [argStart]
    mov rsi, [rsi]
    call printc
    mov r8, rsi

    mov rsi, newline
    mov rdx, 1
    call prints

    mov rdi, r8
    mov rax, SYS_OPEN ; open file
    mov rsi, O_RDONLY ; read only
    syscall ; rax = file descriptor (16bit) (fs)

    cmp eax, 0
    jl _error_file_not_exist

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