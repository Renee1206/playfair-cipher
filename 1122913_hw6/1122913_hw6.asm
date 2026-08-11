INCLUDE Irvine32.inc

Playfair PROTO,
    pKey:PTR BYTE,
    pPlain:PTR BYTE,
    pCipher:PTR BYTE

GetMatrixChar PROTO,
    pMatrix:PTR BYTE,
    targetRow:DWORD,
    targetCol:DWORD

.data

PlayfairKey BYTE 'M','O','N','A','R'
RowSize = ($ - PlayfairKey)            
            BYTE 'C','H','Y','B','D'
            BYTE 'E','F','G','I','K'
            BYTE 'L','P','Q','S','T'
            BYTE 'U','V','W','X','Z'

promptPlain  BYTE "Please input the plaintext: ", 0
promptMod    BYTE "Modified plaintext: ", 0
promptCipher BYTE "The ciphertext is: ", 0

bufferSize = 200
rawInput   BYTE bufferSize DUP(0)
modPlain   BYTE bufferSize DUP(0)
outCipher  BYTE bufferSize DUP(0)

.code
main PROC
    mov edx, OFFSET promptPlain
    call WriteString
   
    mov edx, OFFSET rawInput
    mov ecx, bufferSize
    call ReadString
    cmp eax, 0
    je main_end

    
    ; 明文前置處理 (去除非字母、大寫化、J轉I、重複與奇數長度補X)
    mov esi, OFFSET rawInput
    mov edi, OFFSET modPlain

preprocess_loop:
    mov al, [esi]
    cmp al, 0
    je preprocess_done
    inc esi

    cmp al, 'A'
    jb preprocess_loop
    cmp al, 'Z'
    jbe is_upper
    cmp al, 'a'
    jb preprocess_loop
    cmp al, 'z'
    ja preprocess_loop

    and al, 11011111b

is_upper:
    cmp al, 'J'
    jne store_char
    mov al, 'I'
store_char:
    mov edx, edi
    sub edx, OFFSET modPlain
    test edx, 1
    jz append_directly

    mov bl, [edi-1]
    cmp al, bl
    jne append_directly

    mov BYTE PTR [edi], 'X'
    inc edi
    dec esi
    jmp preprocess_loop

append_directly:
    mov [edi], al
    inc edi
    jmp preprocess_loop

preprocess_done:
    mov edx, edi
    sub edx, OFFSET modPlain
    test edx, 1
    jz format_output_print
    mov BYTE PTR [edi], 'X'
    inc edi

format_output_print:
    mov BYTE PTR [edi], 0

    
    ; 列印格式化後的明文
    mov edx, OFFSET promptMod
    call WriteString
    mov esi, OFFSET modPlain
print_mod_loop:
    mov al, [esi]
    cmp al, 0
    je print_mod_done
    call WriteChar
    mov al, [esi+1]
    call WriteChar
    mov al, ' '
    call WriteChar
    add esi, 2
    jmp print_mod_loop
print_mod_done:
    call Crlf

    
    ; 呼叫 Playfair 加密子程序
    push OFFSET outCipher             
    push OFFSET modPlain              
    push OFFSET PlayfairKey            
    call Playfair                      

    
    ; 列印最終密文結果
    mov edx, OFFSET promptCipher
    call WriteString
    mov esi, OFFSET outCipher
print_cipher_loop:
    mov al, [esi]
    cmp al, 0
    je print_cipher_done
    call WriteChar
    mov al, [esi+1]
    call WriteChar
    mov al, ' '
    call WriteChar
    add esi, 2
    jmp print_cipher_loop
print_cipher_done:
    call Crlf

main_end:
    exit
main ENDP

; Playfair 核心加密程序
Playfair PROC STDCALL USES eax ebx ecx edx esi edi,
    pKey:PTR BYTE,
    pPlain:PTR BYTE,
    pCipher:PTR BYTE

    LOCAL row1:DWORD, col1:DWORD
    LOCAL row2:DWORD, col2:DWORD
    LOCAL pCurrentPlain:DWORD
    LOCAL pCurrentCipher:DWORD

    mov eax, pPlain
    mov pCurrentPlain, eax
    mov eax, pCipher
    mov pCurrentCipher, eax

align_loop:
    mov esi, pCurrentPlain
    mov al, [esi]
    cmp al, 0
    je playfair_done
    mov bl, [esi+1]
    add pCurrentPlain, 2

   
    ; 找第一個字母的一維索引
    mov ecx, 0
    mov edi, pKey
find_c1:
    cmp BYTE PTR [edi + ecx], al
    je found_c1
    inc ecx
    jmp find_c1
found_c1:
    mov ax, cx
    mov dl, RowSize                   
    div dl                            
    movzx edx, al
    mov row1, edx
    movzx edx, ah
    mov col1, edx

   
    ; 找第二個字母的一維索引
    mov ecx, 0
find_c2:
    cmp BYTE PTR [edi + ecx], bl
    je found_c2
    inc ecx
    jmp find_c2
found_c2:
    mov ax, cx
    mov dl, RowSize                   
    div dl                             
    movzx edx, al
    mov row2, edx
    movzx edx, ah
    mov col2, edx

    
    ; 位置關係判斷與字母代換
    mov eax, row1
    cmp eax, row2
    je same_row
    mov eax, col1
    cmp eax, col2
    je same_col

    ; 情況 1：不同行不同列 (交換邊角)
    push col2                          
    push row1                          
    push pKey                          
    call GetMatrixChar                 
    mov dl, al

    push col1                          
    push row2                          
    push pKey                          
    call GetMatrixChar
    mov dh, al
    jmp write_to_cipher

same_row:
    ; 情況 2：同一列 (各自往右取一格)
    mov ebx, col1
    inc ebx
    cmp ebx, RowSize                   
    jne skip_wrap_r1
    mov ebx, 0
skip_wrap_r1:
    push ebx                           
    push row1                          
    push pKey                          
    call GetMatrixChar
    mov dl, al

    mov ebx, col2
    inc ebx
    cmp ebx, RowSize                   
    jne skip_wrap_r2
    mov ebx, 0
skip_wrap_r2:
    push ebx                          
    push row2                         
    push pKey                        
    call GetMatrixChar
    mov dh, al
    jmp write_to_cipher

same_col:
    ; 情況 3：同一行 (各自往下取一格)
    mov eax, row1
    inc eax
    cmp eax, RowSize                   
    jne skip_wrap_c1
    mov eax, 0
skip_wrap_c1:
    push col1                          
    push eax                           
    push pKey                         
    call GetMatrixChar
    mov dl, al

    mov eax, row2
    inc eax
    cmp eax, RowSize                  
    jne skip_wrap_c2
    mov eax, 0
skip_wrap_c2:
    push col2                          
    push eax                           
    push pKey                         
    call GetMatrixChar
    mov dh, al

write_to_cipher:
    mov edi, pCurrentCipher
    mov [edi], dl
    mov [edi+1], dh
    add pCurrentCipher, 2
    jmp align_loop

playfair_done:
    mov edi, pCurrentCipher
    mov BYTE PTR [edi], 0
    ret                                
Playfair ENDP


GetMatrixChar PROC USES ebx ecx esi,
    pMatrix:PTR BYTE,
    targetRow:DWORD,
    targetCol:DWORD

    
    mov ebx, pMatrix                    

    mov eax, targetRow
    mov ecx, RowSize
    imul eax, ecx                       ; eax = row_index * RowSize
    add ebx, eax                        ; ebx = Base pointer + Row Offset
    
    mov esi, targetCol                  ; esi = column_index

    mov al, [ebx + esi]                 

    ret                                
GetMatrixChar ENDP

END main