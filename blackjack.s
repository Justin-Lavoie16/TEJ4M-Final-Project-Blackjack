.global main
.extern printf, scanf

.data
player_score:   .word 0
dealer_score:   .word 0
hit_prompt:     .asciz "Hit or Stand? (h/s): "
format_char:    .asciz " %c"
win_msg:        .asciz "You win!\n"
lose_msg:       .asciz "Dealer wins!\n"
tie_msg:        .asciz "It's a tie!\n"

.text
main:
    bl init_game
    bl player_turn
    bl dealer_turn
    bl determine_winner
    mov r0, #0
    bx lr

init_game:
    bl random_card
    str r0, [r1, #0]         @ player score
    bl random_card
    ldr r1, =player_score
    ldr r2, [r1]
    add r2, r2, r0
    str r2, [r1]

    bl random_card
    ldr r1, =dealer_score
    str r0, [r1]
    bx lr

player_turn:
loop_player:
    ldr r0, =hit_prompt
    bl printf
    ldr r0, =format_char
    ldr r1, =response
    bl scanf
    ldrb r2, [r1]
    cmp r2, #'h'
    bne player_done
    bl random_card
    ldr r1, =player_score
    ldr r2, [r1]
    add r2, r2, r0
    str r2, [r1]
    cmp r2, #21
    bhi player_done
    b loop_player
player_done:
    bx lr

dealer_turn:
    ldr r1, =dealer_score
    ldr r2, [r1]
check_loop:
    cmp r2, #17
    bge dealer_done
    bl random_card
    add r2, r2, r0
    str r2, [r1]
    b check_loop
dealer_done:
    bx lr

determine_winner:
    ldr r1, =player_score
    ldr r2, [r1]
    ldr r3, =dealer_score
    ldr r4, [r3]
    cmp r2, #21
    bhi dealer_wins
    cmp r4, #21
    bhi player_wins
    cmp r2, r4
    beq tie
    bgt player_wins
dealer_wins:
    ldr r0, =lose_msg
    b print_msg
player_wins:
    ldr r0, =win_msg
    b print_msg
tie:
    ldr r0, =tie_msg
print_msg:
    bl printf
    bx lr

@ Return value: r0 = card (2–11)
random_card:
    mov r0, #2
    bx lr

.bss
response: .skip 1
