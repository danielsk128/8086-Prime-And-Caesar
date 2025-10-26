data segment
    main_menu_msg db '>> Select an option:', 13, 10, '$' ; Main menu message
    option_prime_check db '1. Prime number checker', 13, 10, '$' ; Op 1: Prime number check
    option_caesar_encode db '2. Caesars shift coder', 13, 10, '$' ; Op 2: Caesar cipher encoder
    option_exit_program db '3. Exit', 13, 10, '$' ; Op 3: Exit
    input_number_msg db '>> Enter a positive integer number N (2 < N < 255):', 13, 10, '$' ; input for number
    result_prime_msg db 'The number is prime.', 13, 10, '$' ; the number is prime
    result_not_prime_msg db 'The number is not prime.', 13, 10, '$' ; the number isn't prime
    input_string_msg db '>> Type a string (only small characters in English):', 13, 10, '$' ; string input
    input_shift_msg db '>> Enter one decimal digit (between 2 to 9):', 13, 10, '$' ; shifting
    buffer_num dw 20 dup (0) 
    buffer_str db 20 dup (0)  
    encoded_str db 20 dup (0)
    user_input_num dw ?  
    at_char db '@$' ; drawing the triangle
    star_char db '*$' ; drawing the square
    shift_val db ? ; Variable to store the Caesar cipher shift value
data ends

code segment
assume cs:code, ds:data

start:

    ; Set up the data segment
    mov ax, data
    mov ds, ax

main_loop:

    ; Display the main menu
    call display_main_menu
    mov ah, 1
    int 21h
    
    ; Check user input 
    cmp al, '3'
    je end_program
    cmp al, '1'
    je prime_number_checker
    cmp al, '2'
    jmp caesar_cipher

    ; Return to main menu if input is incorrect
    jmp main_loop

end_program:
    
    ; Terminate the program
    mov ah, 4Ch
    int 21h

display_main_menu:

    ; Print the main menu and options
    call print_newline
    mov dx, offset main_menu_msg
    call display_text

    call print_newline
    mov dx, offset option_prime_check
    call display_text

    call print_newline
    mov dx, offset option_caesar_encode
    call display_text

    call print_newline
    mov dx, offset option_exit_program
    call display_text

    call print_newline

    mov ah, 1
    int 21h
    cmp al, '3'
    je end_program
    cmp al, '1'
    je prime_number_checker
    jmp caesar_cipher

prime_number_checker:

    ; Check if the input number is prime
    call get_user_number
    call check_prime_number
    cmp al, 1
    je display_prime_result
    call display_not_prime_result
    jmp main_loop

get_user_number proc

    ; User input (a number)
    call print_newline
    mov dx, offset input_number_msg
    call display_text
    call print_newline

    mov si, offset buffer_num
    xor bx, bx

input_number_loop:

    ; Get each digit of the number
    mov ah, 1
    int 21h

    ; Check if the user finished input
    cmp al, '.'

    ; Convert ASCII to digit
    je convert_input_to_number
    sub al, '0'
    sub ah, ah
    mov buffer_num[bx], ax
    inc bx

    ; Loop to get the next digit
    jmp input_number_loop

convert_input_to_number:

    ; Convert the input digits to a full number
    xor di, di      ; DI == 0    
    mov cx, 1           

convert_loop:
    dec bx              
    mov ax, buffer_num[bx]
    mul cx              
    add di, ax          
    mov cx, 10          
    cmp bx, 0

    ; Continue if there are more digits
    jne convert_loop    

    ; Store the final number
    mov user_input_num, di 
    ret
get_user_number endp

check_prime_number proc

    ; Check if the number is prime
    mov bx, 2
    mov cx, user_input_num

prime_check_loop:
    mov ax, bx
    mul bx ; Calculate bx^2
    cmp ax, cx

    ; it is prime
    ja prime_found

    mov ax, cx
    xor dx, dx
    div bx
    cmp dx, 0

    ; is not prime
    je not_prime_found

    inc bx
    jmp prime_check_loop

not_prime_found:

    ; If the number is not prime print the message
    call print_newline
    mov dx, offset result_not_prime_msg
    call display_text
    xor al, al
    ret

prime_found:

    ; If the number is prime print the message
    call print_newline
    mov dx, offset result_prime_msg
    call display_text
    mov al, 1
    ret
check_prime_number endp

display_prime_result:
    call draw_at_triangle
    jmp main_loop

draw_at_triangle proc
    call print_newline
    mov cx, 1

triangle_loop_outer:
    mov bx, cx

triangle_loop_inner:
    mov dx, offset at_char
    call display_text
    dec bx
    cmp bx, 0
    jne triangle_loop_inner

    call print_newline
    inc cx
    cmp cx, user_input_num
    jle triangle_loop_outer

    ret
draw_at_triangle endp

display_not_prime_result:

    ; Draw a square - is not prime
    call draw_star_square
    jmp main_loop

draw_star_square proc
    mov cx, user_input_num
    mov bx, user_input_num
    inc cx

square_loop_row:
    call print_newline
    dec cx
    cmp cx, 0
    je end_square_display
    mov bx, user_input_num

square_loop_col:
    mov dx, offset star_char
    call display_text
    dec bx
    cmp bx, 0
    jne square_loop_col
    jmp square_loop_row

end_square_display:
    ret
draw_star_square endp

caesar_cipher:

    ; Perform Caesar cipher encoding
    call get_input_string
    call get_shift_value

    call encrypt_caesar_loop

    mov dx, offset encoded_str

    call display_text
    call print_newline
    jmp main_loop

get_input_string proc

    ; Get a string from the user
    call print_newline
    mov dx, offset input_string_msg
    call display_text
    xor bx, bx


string_input_loop:

    ; Get each character of the string
    mov ah, 1
    int 21h
    cmp al, '.'
    je get_shift_value
    mov buffer_str[bx], al
    inc bx
    jmp string_input_loop
    ret
get_input_string endp

get_shift_value proc

    ; Get the shift value for the Caesar cipher
    mov buffer_str[bx], '$'
    call print_newline
    mov dx, offset input_shift_msg
    call display_text
    mov ah, 1
    int 21h
    sub al, '0'
    mov shift_val, al
    xor bx, bx
    mov si, offset buffer_str
    call print_newline

    mov di, offset encoded_str
get_shift_value endp


encrypt_caesar_loop:

    ; Load the current character
    mov al, buffer_str[bx]
    cmp al, 'a'
    jl skip_encryption
    cmp al, 'z'
    jg skip_encryption

    add al, shift_val
    cmp al, 'z'
    jle encrypt_char
    sub al, 26

encrypt_char:
    mov [di], al
    jmp continue_encrypt

skip_encryption:
    mov [di], al

continue_encrypt:
    inc bx
    inc di
    cmp buffer_str[bx], '$'

    ; Continue till the end of string
    jne encrypt_caesar_loop

    mov byte ptr [di], '$'
    mov dx, offset encoded_str
    call display_text
    call print_newline
    jmp main_loop

print_newline proc
    mov dl, 13
    mov ah, 2
    int 21h
    mov dl, 10
    mov ah, 2
    int 21h
    ret
print_newline endp

display_text proc
    mov ah, 9
    int 21h
    ret
display_text endp

code ends
end start
