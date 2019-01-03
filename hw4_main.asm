.data
map_filename: .asciiz "map1.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments

#print the map data
move $t1, $t0
addi $t1, $t1, 2


lb $t2, 0($t0)	#number of rows
lb $t3, 1($t0)	#number of cols
printMapOuterLoop:
	#print new line char
	li $a0, 10
	li $v0, 11
	syscall
	
	move $t5, $t3
	addi $t2, $t2, -1
	beq $t2, -1, exitPrintMap
	
	printMapInnerLoop:
		#print char
		lbu $a0, 0($t1)
		li $v0, 11
		syscall
		#iterate to next char
		addi $t1, $t1, 1
		#subtract temp col variable 
		addi $t5, $t5, -1
		beqz $t5, printMapOuterLoop
		j printMapInnerLoop

exitPrintMap:
jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player

la $a0, pos_str
li $v0, 4
syscall

lb $a0, 0($t0)	#row
li $v0, 1
syscall

li $a0, 44	#comma
li $v0, 11
syscall

lb $a0, 1($t0)	#colomn
li $v0, 1
syscall

la $a0, health_str
li $v0, 4
syscall

lb $a0, 2($t0)
li $v0, 1
syscall

la $a0, coins_str
li $v0, 4
syscall

lb $a0, 3($t0)
li $v0, 1
syscall




jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game


# fill in arguments
la $t0, player
la $a0, map
lb $a1, 0($t0)
lb $a2, 1($t0)
jal reveal_area



li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

beq $s1, 119, passU
beq $s1, 97, passD
beq $s1, 115, passL
beq $s1, 100, passR




# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()
passU:
	la $a0, map
	la $a1, player
	li $a2, 85
	jal player_turn
passD:
	la $a0, map
	la $a1, player
	li $a2, 68
	jal player_turn

passL:
	la $a0, map
	la $a1, player
	li $a2, 76
	jal player_turn

passR:
	la $a0, map
	la $a1, player
	li $a2, 82
	jal player_turn

# if move == 0, call reveal_area()  Otherwise, exit the loop.
beq $s0, 0, goReveal
j game_over
goReveal:
	la $t0, player
	la $a0, map
	lb $a1, 0($t0)
	lb $a2, 1($t0)
	jal reveal_area
overThisPart:

jal print_map



j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "hw4.asm"
