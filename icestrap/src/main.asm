%include "linux.inc"
%include "libcold.asm"
; %include "mem.asm"


[section .data]
    newline db 10
    text0 db "Open File: "
    text0Len equ $ - text0
    text1 db "No file given", 10
    text1Len equ $ - text1

[section .bss]
    argCount resb 8
    path resb 8 ; ptr ptr char
    argStart resb 8 ; ptr ptr[char]
    ; path and argStart must be derefed 2x
    ; argStart indexing is at the second deref
[section .text]
global _start

_start:
    ; copy command line argument pointers
    ; init stack looks like this
    ; argument Count <- rsp
    ; path
    ; argument 1 <- root compilation file path
    ; argument n
    ; rsp
    ; rbp <- rbp
    mov rax, [rsp]
    dec rax ; dec to treat arguments different from the path
    mov [argCount], rax
    mov rax, rsp
    add rax, 8
    mov [path], rax
    add rax, 8
    mov [argStart], rax
    
    push rbp
    mov rbp, rsp ; prologue
    
    mov rax, [argCount]
    cmp rax, 0
    jz _no_param_ext ; no file supplied in cmd args, end
            
    mov rsi, text0
    mov rdx, text0Len
    call _print
   
    mov rsi, [argStart]
    mov rsi, [rsi]
    call strlen
    mov rdx, rax
    call _print
    mov r8, rsi

    mov rsi, newline
    mov rdx, 1
    call _print

    mov rdi, r8
    mov rax, SYS_OPEN ; open file
    mov rsi, O_RDONLY ; read only
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

; prints null terminated string to stdout
; calls _string_length
; takes: rsi
; modifies: rax, rdi, rdx, rcx
_printC:
    call strlen_sse4
    mov rdx, rax
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall
    ret

; prints string
; takes: rsi, rdx
; modifies: rax, rdi
_print:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall
    ret

_no_param_ext:
    mov rsi, text1
    mov rdx, text1Len
    call _print
    exit 7 
