.data
prompt:     .asciz "Guess a number between 0 and 9: "
too_low:    .asciz "Too low!\n"
too_high:   .asciz "Too high!\n"
correct:    .asciz "Correct! You guessed it!\n"
input_err:  .asciz "Invalid input! Please enter 0-9.\n"
newline:    .asciz "\n"

think_msg:  .asciz "\nNow think of a number between 0 and 9. I will try to guess it!\n"
comp_guess_msg: .asciz "Is it "
guess_suffix:   .asciz "? (l=low, h=high, c=correct): "
comp_correct:   .asciz "Yay! I guessed your number!\n"

.bss
.lcomm input, 10

.text
.global _start
_start:
    @ Get time as seed
    mov r7, #0x7D       @ syscall: time
    mov r0, #0
    svc #0              @ r0 = time

    @ r0 now contains seed
    mov r4, r0          @ copy seed to r4
    mov r1, #10         @ divisor for mod 10

    udiv r3, r4, r1     @ r3 = r4 / 10
    mul r2, r3, r1      @ r2 = (r4 / 10) * 10
    sub r4, r4, r2      @ r4 = r4 % 10 => target number

game_loop:
    ldr r0, =prompt
    bl print_string

    ldr r1, =input
    mov r2, #10
    mov r7, #3          @ syscall: read
    mov r0, #0          @ stdin
    svc #0
    cmp r0, #0
    beq invalid_input

    ldr r1, =input
    ldrb r2, [r1]
    cmp r2, #0xA
    beq invalid_input
    sub r2, r2, #'0'    @ convert ASCII to number

    cmp r2, #0
    blt invalid_input
    cmp r2, #9
    bgt invalid_input

    cmp r2, r4
    beq guessed_right
    blt label_too_low

label_too_high:
    ldr r0, =too_high
    bl print_string
    b game_loop

label_too_low:
    ldr r0, =too_low
    bl print_string
    b game_loop

invalid_input:
    ldr r0, =input_err
    bl print_string
    b game_loop

guessed_right:
    ldr r0, =correct
    bl print_string

    @ Start second phase: computer guesses user's number
    bl comp_guess_phase

    mov r7, #1
    mov r0, #0
    svc #0

comp_guess_phase:
    push {r4-r11, lr}

    ldr r0, =think_msg
    bl print_string

    mov r5, #5      @ starting guess = 5 (use r5 for guess)

guess_loop:
    @ Print "Is it <number>? (l=low, h=high, c=correct):"
    ldr r0, =comp_guess_msg
    bl print_string

    add r0, r5, #'0'    @ convert guess to ASCII
    bl print_char

    ldr r0, =guess_suffix
    bl print_string

    @ Read user input
    ldr r1, =input
    mov r2, #10
    mov r7, #3
    mov r0, #0
    svc #0

    ldr r1, =input
    ldrb r2, [r1]

    cmp r2, #'l'
    beq guess_too_low

    cmp r2, #'h'
    beq guess_too_high

    cmp r2, #'c'
    beq guess_correct

    b guess_loop     @ Invalid input → retry

guess_too_low:
    add r5, r5, #1
    cmp r5, #9
    bgt set_to_9
    b guess_loop

guess_too_high:
    sub r5, r5, #1
    cmp r5, #0
    blt set_to_0
    b guess_loop

set_to_0:
    mov r5, #0
    b guess_loop

set_to_9:
    mov r5, #9
    b guess_loop

guess_correct:
    ldr r0, =comp_correct
    bl print_string
    pop {r4-r11, pc}

print_string:
    push {r4, lr}
    mov r4, r0

    mov r1, r0
    mov r2, #0
1:  ldrb r3, [r1], #1
    cmp r3, #0
    addne r2, r2, #1
    bne 1b

    mov r7, #4
    mov r0, #1
    mov r1, r4
    svc #0

    pop {r4, pc}

print_char:
    push {r1-r3, lr}
    sub sp, sp, #4
    strb r0, [sp]
    mov r7, #4
    mov r0, #1
    mov r1, sp
    mov r2, #1
    svc #0
    add sp, sp, #4
    pop {r1-r3, pc}
