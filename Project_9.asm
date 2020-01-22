
; Project_9 RC4-Based Random Generator
 
; Name: Ahmed Mohamed Salah El-Dein Radwan
; ID  : 39


org 100h

; add your code here 
                                  
jmp start  
                  
; Messages                             
; define variables:

 msg1 db 0Dh,0Ah, " Please Enter the Key Length which is a Number between 1 and 256 : $"                 
 msg2 db 0Dh,0Ah, " Now Please Enter the Key : $"                 
 msg3 db 0Dh,0Ah, " The Output Key is : $"                 
                    
                   
start: 
                              
;Key-scheduling algorithm (KSA)

; Create the Array S 
Array_S         DB  256 dup(0)

mov CX,0
mov SI,0

LOOP_S: mov Array_S[SI],Cl
        INC CL
        INC SI
        cmp SI, 255
        JLE LOOP_S

 
i         DW  0
j         DW  0  
KeyLength DW  0  

mov cx, 0       ;Prevents junk data from showing up

mov dx, 0       ;Prevents junk data from showing up
                 
; Get the Key Length       
lea dx, msg1
mov ah, 09
int 21h 

mov dl, 10  
scanNum_1:
              
            mov ah, 01h
            int 21h

            cmp al, 13   ; Check if user pressed ENTER KEY
            je  exit 

            mov ah, 0  
            sub al, 48   ; ASCII to DECIMAL

            mov cl, al
            mov al, bl   ; Store the previous value in AL

          
            mul dl       ; multiply the previous value with 10

            add al, cl   ; previous value + new value ( after previous value is multiplyed with 10 )
            mov bl, al

            jmp scanNum_1    

exit:    
            mov BH,0
            mov KeyLength,BX
            cmp KeyLength, 0 
            jne  not_zero_1 
            
            mov KeyLength,256
                      
not_zero_1:                         
            
; Initialize the Key
Key       DB  KeyLength dup(0)

mov dx, 0       ;Prevents junk data from showing up

mov CX,0
mov SI,0

; Get the Key        
lea dx, msg2
mov ah, 09
int 21h 

mov dl, 10  
scanNum_2:
              
            mov ah, 01h
            int 21h
                       
            sub al, 48   ; ASCII to DECIMAL

            
            Mov Key[SI],AL
            
           
            INC SI
            INC CX
            cmp CX,KeyLength
            
            jl  scanNum_2
           
                              
                               
LOOP_kSA:  MOV AX,i
           CWD  
           AND DX,0
           MOV BX,KeyLength 
           DIV BX 
           MOV SI,DX 
           ;AND SI,01FFh 
                        
           
           MOV Al,key[sI]              ;Adds the remainder of division to the rest of expression
           CBW
           AND AX,00FFh 
           
           MOV SI,i
           MOV BX,0000h
           MOV BL,Array_S[SI]
           
           ADD AX,BX
           ;AND AX,00FFh
            
           ADD AX,j
           ;AND AX,00FFh
           CWD
           AND DX,0 
           MOV BX,256
           DIV BX
           MOV j,DX
           ;AND j,00FFh
           
           ;Swap the Two elements
           MOV SI,i 
           MOV DI,j
           MOV Bl,Array_S[DI]
           MOV BH,Array_S[SI]
           MOV Array_S[DI],BH
           MOV Array_S[SI],Bl
           
           
           inc i 
           cmp i, 255
           JLE LOOP_kSA                             
                

    
;Pseudo-random generation algorithm (PRGA)

 ; Create the Array K 
 Array_K         DB  KeyLength  dup(0)

 
 MOV i,0
 MOV j,0 
 MOV CX,0 
  
 
LOOP_PRGA:   INC i
             MOV AX,i
             CWD
             MOV DX,0
             MOV BX,256
             DIV BX
             MOV i,DX 
             
             
             MOV SI,i
             MOV AX,0 
             MOV Al,Array_S[SI] 
             ADD AX,j
             CWD
             MOV DX,0
             MOV BX,256
             DIV BX
             MOV j,DX  
             
             ;Swap the Two elements
                       MOV SI,i 
                       MOV DI,j
                       MOV Bl,Array_S[DI]
                       MOV BH,Array_S[SI]
                       MOV Array_S[DI],BH
                       MOV Array_S[SI],Bl
                       
             
             MOV SI,i 
             MOV DI,j   
             MOV AX,0
             MOV Al,Array_S[SI] 
             ADD Al,Array_S[DI]
             CWD
             MOV DX,0
             MOV BX,256
             DIV BX
             MOV SI,DX
             
             ;Fill the output K  
             MOV BL,Array_S[SI]
             MOV CH,0
             MOV SI,CX   
             MOV Array_K[SI],BL  
             
             
             INC CX
             cmp CX,KeyLength
             JL  LOOP_PRGA


;XOR S and K
MOV SI,0
MOV DI,0
MOV AX,0
  
LOOP_XOR:    MOV Al,Key[SI]
             XOR Array_K[DI],AL
             INC SI
             INC DI
             cmp SI,KeyLength
             JL  LOOP_XOR







             
;Output K
          
lea dx, msg3
mov ah, 09
int 21h 

mov dl, 10  


MOV SI,0

Print_the_key:          
                                                  
             ;Load the Key digit by digit
             MOV AX,0 
             MOV AL,Array_K[SI] 
             
             ;Print the Key  
             CALL PRINT 
             
             ;Print space between each digit
             MOV dx,32 
             mov ah,02h 
             int 21h 
                
                         
             INC SI
             cmp SI,KeyLength
             JL  Print_the_key                


ret     ; return back to os.



  
PRINT PROC            
      
    ;initilize count 
    mov cx,0 
    mov dx,0 
    label1: 
        ; if ax is zero 
        cmp ax,0 
        je print1       
          
        ;initilize bx to 10 
        mov bx,10         
          
        ; extract the last digit 
        div bx                   
          
        ;push it in the stack 
        push dx               
          
        ;increment the count 
        inc cx               
          
        ;set dx to 0  
        xor dx,dx 
        jmp label1 
    print1: 
        ;check if count  
        ;is greater than zero 
        cmp cx,0 
        je exit_print
          
        ;pop the top of stack 
        pop dx 
          
        ;add 48 so that it  
        ;represents the ASCII 
        ;value of digits 
        add dx,48 
          
        ;interuppt to print a 
        ;character 
        mov ah,02h 
        int 21h 
          
        ;decrease the count 
        dec cx 
        jmp print1 
exit_print: 
ret 
PRINT ENDP   
  

