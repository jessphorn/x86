;--------------------------------------------------------------------------
;
;   Program:   dcomp
;
;   Author: Jessica Horn
;
;   Function:  Dcomp decompresses ASCII text.
;
;   Input:
;   - si points to the string of compressed data
;   - di points to the empty list into which the decompressed data is stored
;
;   Output:
;
;   - The compressed data is decompressed into output list
;   - The compressed data is not modified
;   - All registers contain their original value except ax
;     ax = 1...n = size of decompressed data
;
;   Date:      Changes
;   ---------- -------
;   10/06/2016 Basic shell created
;   03/27/2017 1st attempt
;   03/28/2017 increased efficiency and added comments
;------------------------------------------------------
         .model    small                              ;64k code and 64k data
         .8086                                        ;only allow 8086 instructions
         public    dcomp                              ;allow linker to access  dcomp
         public    getbit                             ;allow linker to access  getbit
;------------------------------------------------------
         .data                                        ;start the data segment
;------------------------------------------------------
t0xx      db         ' ETA'                           ;table of frequently used characters
t10xxxxx  db        'BCDFGHIJKLMNOPQRSUVWXYZ'         ;table of uppercase letters
t11xxxx   db        ' 1234567890.',0dh,0ah,' ',1ah    ;table of numbers, period, and line/file termination characters
;------------------------------------------------------
         .code                                        ;starts the code segment
;------------------------------------------------------
; Save the registers that will be used.
;------------------------------------------------------
dcomp:                                                ;              
         push      bx                                 ;save the bx register
         push      dx                                 ;save the dx register
         push      cx                                 ;save the cx register
         push      si                                 ;save the si register
         push      di                                 ;save the di register
         mov       dx,0                               ;set dx to 0
         mov       ax,0                               ;set the counter to 0
;------------------------------------------------------
; Get the first bit and determine whether it indicates
; a frequently used character.
;------------------------------------------------------
start:                                                ;
         mov       bx,0                               ;set the index to 0
         call      getbit                             ;get the next bit 
         jc        infrequent                         ;if carry flag is 1 (1st bit is 1) go to code for infrequent characters
;------------------------------------------------------
; Get the remaining bits of a frequently used character
; and translate them to ascii code.
;------------------------------------------------------
frequent:                                             ;
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         mov       cl,[t0xx + bx]                     ;get the char's ascii code
         jmp       store                              ;go to exit code
;------------------------------------------------------
; Get the second bit and determine wheter it indicates
; an uppercase letter.
;------------------------------------------------------
infrequent:                                           ;
         call      getbit                             ;get the next bit
         jc        other                              ;if carry flag is 1 (2nd bit is 1) go to code for numbers and special characters
;------------------------------------------------------
; Get the remaining bits of an uppercase character and
; translate them to ascii code.
;------------------------------------------------------
uppercase:                                            ;
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         mov       cl,[t10xxxxx + bx]                 ;get the char's ascii code
         jmp       store                              ;go to exit code
;------------------------------------------------------
; Get the remaining bits of the character and translate
; them to ascii code. 
;------------------------------------------------------
other:                                                ;
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index
         sal       bx,1                               ;shift the index left one bit
         call      getbit                             ;get the next bit
         adc       bx,0                               ;add the bit into the index        
         mov       cl,[t11xxxx + bx]                  ;get the char's ascii code
;------------------------------------------------------
; Store the character in di and increase the count.
;------------------------------------------------------
store:                                                ;
         mov       [di],cl                            ;move the char to the list pointed to by di
         inc       di                                 ;move the di pointer to the next position
         inc       ax                                 ;increase the counter
         cmp       cl,1ah                             ;compare the char to the eof character
         jne       start                              ;if not eof, return to start to read the next character  
;------------------------------------------------------
; Store the count of characters in ax and restore the
; registers.
;------------------------------------------------------
exit:                                                 ;
         pop       di                                 ;restore the di register
         pop       si                                 ;restore the si register
         pop       cx                                 ;restore the cx register
         pop       dx                                 ;restore the dx register
         pop       bx                                 ;restore the bx register
         ret                                          ;return
;------------------------------------------------------
; Determine the next bit in the data stream
;------------------------------------------------------
         .data                                        ;start the data segment
;------------------------------------------------------
         .code                                        ;start the code segment
;------------------------------------------------------
; Program:  getbit
;
; Author:   Jessica Horn
;
; Function: Determines the next bit in the bit stream
;
; Input:    si points to a string of compressed data
;
; Output:   The bit is returned to dcomp in the carry
;           flag.
;
; Date         Changes
; 03/27/2017   1st attempt
; 03/28/2017   increased efficiency and added comments
;------------------------------------------------------
getbit:                                               ;
         cmp       dh,0                               ;check for bits in the current data byte
         jne       bit                                ;if there are bits remaining, go to code to get the next bit
         mov       dl,[si]                            ;store the next byte in dl
         mov       dh,8                               ;8 bits are available for processing
         inc       si                                 ;advance the input pointer
;------------------------------------------------------
; Store the next bit in ax
;------------------------------------------------------
bit:                                                  ;
         sal       dl,1                               ;move the next bit int cf
         dec       dh                                 ;reduce the number of bits available in dl
         ret                                          ;return
         end                                          ;end source code
