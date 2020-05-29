;-------------------------------------------------------------------------------------------------
;         Program:  EXPR
; 
;         Function: This program lines of characters from a text file and determines if each
;                   line is a valid expression. It outputs to a text file and indicates whether 
;                   each line is valid, has an invalid variable, or has an invalid format
;
;                   It assumes that all lines end with a CR/LF.
;                   It assumes that all files end with a EOF.
;
;                   To run the file type : EXPR < in_file > out_file
;                   in_file is the name of the input file.
;                   out_file is the name of the output file.
;
;         Owner:    Jessica Horn
;         Date:     Changes:
;         2/23/2017 Original version
;-------------------------------------------------------------
          .model     small                                   ; 64k code and 64k data
          .8086                                              ; only allow 8086 instructions
          .stack     256                                     ; reserve 356 bytes for the stack
;-------------------------------------------------------------
          .data                                              ; start the data segment
;-------------------------------------------------------------
valid     db         'LINE IS VALID', 13, 10, '$'            ; the valid line message
inv_var   db         'INVALID VARIABLE', 13, 10, '$'         ; the invalid variable message
inv_for   db         'INVALID FORMAT', 13, 10, '$'           ; the invalid format message
null      db         13, 10, '$'                             ; null line
state     db         0                                       ; keeps track of the current state
char      db         0                                       ; the character being processed
char_tran db         13 dup (40h)                            ; other characters                    
          db         30h                                     ; end of line character
          db         18 dup (40h)                            ; other characters
          db         10h                                     ; space character
          db         10 dup (40h)                            ; other characters
          db         20h                                     ; operator character
          db         40h                                     ; other character
          db         20h                                     ; operator character
          db         15 dup (40h)                            ; other characters
          db         20h                                     ; operator character
          db         3 dup (40h)                             ; other characters
          db         26 dup (00h)                            ; variable characters
          db         165 dup (40h)                           ; other characters
st_tran   db         2 dup (02h)                             ; start of variable state
          db         06h                                     ; invalid variable state
          db         3 dup (05h)                             ; invalid format state
          db         06h                                     ; invalid variable state
          db         07h                                     ; valid line state
          db         8 dup (09h)                             ; not a state
          db         00h                                     ; initial state
          db         01h                                     ; looking for variable state
          db         2 dup (03h)                             ; looking for operator state
          db         01h                                     ; looking for variable state
          db         05h                                     ; invalid format state
          db         06h                                     ; invalid variable state
          db         9 dup (09h)                             ; not a state
          db         2 dup (05h)                             ; invalid format state   
          db         06h                                     ; invalid variable state
          db         04h                                     ; start of operator state
          db         2 dup (05h)                             ; invalid format state
          db         06h                                     ; invalid variable state
          db         9 dup (09h)                             ; not a state
          db         07h                                     ; valid line state
          db         05h                                     ; invalid format state
          db         2 dup (07h)                             ; valid line state
          db         2 dup (05h)                             ; invalid format state 
          db         06h                                     ; invalid variable state
          db         9 dup (09h)                             ; not a state
          db         2 dup (05h)                             ; invalid format state
          db         06h                                     ; invalid variable state
          db         3 dup (05h)                             ; invalid format state
          db         06h                                     ; invalid variable state
          db         185 dup (09h)                           ; not a state
;-------------------------------------------------------------
          .code                                              ; start the code segment
;-------------------------------------------------------------
; Establish addressability to the data segment.
;-------------------------------------------------------------
start:                                                       ;
          mov        ax,@data                                ; set addressability
          mov        ds,ax                                   ; to the data segment
;-------------------------------------------------------------
; Read and write a character.
;-------------------------------------------------------------
read:                                                        ;
          mov        ah,8                                    ; code to read without echo
          int        21h                                     ; read a character
          mov        dl,al                                   ; move the character to dl
          mov        ah,2                                    ; set to write
          int        21h                                     ; write the chararacter
          cmp        dl,1Ah                                  ; compare the character to exit
          je         exit                                    ; if the character is eof, then go to exit
;-------------------------------------------------------------
; Translate the character and determine the new state given the
; current state.
;-------------------------------------------------------------
translate:                                                   ;
          mov        al,dl                                   ; move the character to the al
          mov        bx, offset char_tran                    ; bx points to the char_tran table
          xlat                                               ; translate the character
          add        al,state                                ; adds the current state to the character value in the al
          mov        bx, offset st_tran                      ; bx points to the st_tran table
          xlat                                               ; translate the state
          mov        state,al                                ; move the contents of al to the current state
          cmp        dl,0Ah                                  ; compare the character to eol
          jne        read                                    ; if the character is not eol, return to read to continue processing
;-------------------------------------------------------------
; Determine which message to output.
;-------------------------------------------------------------
message:                                                     ;
          mov        ah,9                                    ; set dos to write a string
          cmp        state,05h                               ; compare the current state invalid format state
          je         format                                  ; if the current state is invalid format, go to format
          cmp        state,06h                               ; compare the current state to the invalid variable state
          je         variable                                ; if the current state is invalid variable, go to variable
          mov        dx, offset valid                        ; else, point to the valid line message
;-------------------------------------------------------------
; Write the selected message, followed by a null line and  
; return to read to process the next line. 
;-------------------------------------------------------------
eol:                                                         ;
          int        21h                                     ; write the string
          mov        ah,9                                    ; set dos to write a string
          mov        dx, offset null                         ; point to the null line
          int        21h                                     ; write the string
          mov        state,0                                 ; reset the fsm to the initial state
          jmp        read                                    ; return to read to start a new line
;-------------------------------------------------------------
; Set the dx to point to the invalid format message
;-------------------------------------------------------------
format:                                                      ;
          mov        dx, offset inv_for                      ; point to the invalid format message
          jmp        eol                                     ; go to eol 
;-------------------------------------------------------------
; Set the dx to point the the invalid variable message
;-------------------------------------------------------------
variable:                                                    ;
          mov        dx, offset inv_var                      ; point to the invalid variable message
          jmp        eol                                     ; go to eol
;-------------------------------------------------------------
; When the terminating character has been read and echoed,
; return to DOS.
;-------------------------------------------------------------
exit:                                                        ;
          mov        ax,4C00h                                ; set the exit code in ax
          int        21h                                     ; int 21h will terminate the program
          end        start                                   ; execution begins at the label start
          


