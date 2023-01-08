%include "../../../driplib/include/linux.inc"

[section .rodata]:
    errorFileMissing db "No file given", 10
    errorFileMissingLen equ $ - errorFileMissing
    errorFileNotExist db "File does not exist", 10
    errorFileNotExistLen equ $ - errorFileNotExist

_error_file_missing:
    lea rsi, errorFileMissing
    mov rdx, errorFileMissingLen
    call prints

    exit 1

_error_file_not_exist:
    lea rsi, errorFileNotExist
    mov rdx, errorFileNotExistLen
    call prints

    exit 1
