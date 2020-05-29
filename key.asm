;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;     Program:  Key
;
;     Function: This program reads characters from the standard input device. This
;               can be the keyboard or a file that has been redirected to the 
;               standard input.
;
;               It allows the software to examine each character.
;
;               Uppercase characters 'A' - 'Z', the space character, and '.' are
;               written to the standard output device as is. The lowercase
;               characters 'a' - 'z' are converted to uppercase before being written
;               to the output device. Any other characters are not written to the
;               output device. The output device can be the display or a file that
;               has been redirected to the standard output.
;
;               The program terminates when the character that has been read and 
;               echoed matches the character stored in the variable named 
;               'end_char'. The 'end_char' is set to 2eh, the '.' character.
;
;               There are four possible combinations for reading and writing data:
;               ------------------------------------------------------------------
;               key                      input = keyboard     output = display 
;               key < input              input = file         output = display
;               key > output             input = keyboard     output = file
;               key < input > output     input = file         output = file
;
;     Owner:    Jessica Horn
;   
;     Date:     Changes:
;     2/2/2017  Original version
;
;------------------------------------------------------
          .model     small                            ; 64k code and 64k data
          .8086                                       ; only allow 8086 instructions
          .stack     256                              ; reserve 256 bytes for the stack
;------------------------------------------------------
          .data                                       ; start the data segment
;------------------------------------------------------
end_char  db         2eh                              ; termination character
tran      db         32 dup ('*')                     ; the 32 characters before the space character
          db         ' '                              ; the space character
          db         13 dup ('*')                     ; the 13 characters between ' ' and '.'
          db         '.'                              ; the '.' character
          db         18 dup ('*')                     ; the 18 characters between '.' and 'A'
          db         'ABCDEFGHIJKLMNOPQRSTUVWXYZ'     ; A-Z in uppercase
          db         6 dup ('*')                      ; the 6 characterw beteen 'Z' and 'a'
          db         'ABCDEFGHIJKLMNOPQRSTUVWXYZ'     ; a-z in lowercase
          db         133 dup ('*')                    ; the 133 characters after 'z'
;------------------------------------------------------
          .code                                       ; start the code segment
;------------------------------------------------------
; Establish adressabiltity to the data segment.
;------------------------------------------------------
start:                                                ;
          mov        ax,@data                         ; set addressability
          mov        ds,ax                            ; to the data segment
;------------------------------------------------------
; Read a character without echo.
;------------------------------------------------------
getloop:                                              ;
          mov        bx,offset tran                   ; bx points to the table
          mov        ah,8                             ; code to read without echo
          int        21h                              ; read a character
;------------------------------------------------------
; Translate the character and return to getloop if it
; is '*'.
;------------------------------------------------------
          xlat                                        ; translate the character
          mov        dl,al                            ; move the character to dl
          cmp        dl,2ah                           ; compare the contents of dl to 2ah - '*'
          je         getloop                          ; if the contents of dl is 2ah, return to getloop
;------------------------------------------------------
; Write the character and return to getloop if it is
; not the termination character.
;------------------------------------------------------ 
          mov        ah,2                             ; code to write the character
          int        21h                              ; write the character
          cmp        dl,[end_char]                    ; compare the contents of dl to end_char - '.'
          jne        getloop                          ; if the contents of dl is not the end_char, return to getloop
;------------------------------------------------------
; When the terminating character has been read and
; echoded, return to DOS.
;------------------------------------------------------
exit:                                                 ; we processeed the terminating character
          mov        ax,4c00h                         ; set correct exit code in ax
          int        21h                              ; in 21 will terminate the program
          end        start                            ; execution begins at the label start
;------------------------------------------------------
        