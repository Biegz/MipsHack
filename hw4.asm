# Austin Biegler
# ABIEGLER
# 111811922

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:
li $v0, -200
li $v1, -200

#Save the a registers
move $t7, $a0	#map_filename
move $t8, $a1	#map pointer
move $t9, $a2	#player pointer



#Open the File
move $a0, $a0
li $a1, 0	#0 for reading
li $a2, 0	#mode is ignored
li $v0, 13
syscall
bltz $v0, returnError1
move $t0, $v0 	#move the file descriptor to $t0
addi $sp, $sp, -1	#make space on stack for syscall 14



#Read the First 2 bytes from MAP_DATA
li $t1, 0	#miscellaneous counter
readFromFileLoop:
addi $t1, $t1, 1
#Read one byte from the file
move $a0, $t0	#$t0 holds the file descriptor from the last syscall
move $a1, $sp	#using a byte on the stack as the input buffer
li $a2, 1	#1 because thats the amount of bytes we want to be read into the mem buffer
li $v0, 14
syscall

lbu $t2, 0($sp)
beq $t2, 10, readFromFileLoop	#if the byte read is a new line char
beq $t1, 1, convertRowCol
beq $t1, 2, addToTensPlace
beq $t1, 4, convertRowCol
beq $t1, 5, addToTensPlace

#Read map Data (STILL HAVE TO ADD THE HIDDEN FEATURE AND FIND WHERE @ IS)
readMapData:
move $t1, $t8
addi $t1, $t1, 2	#pointer for storing at cells[][] is in $t1

ori $t2, $t2, 0x80
sb $t2, 0($t1)
addi $t1, $t1, 1

li $t6, -1	#counter for columns
li $t5, -1	#counter for rows
readMapOuterLoop:
	addi $t5, $t5, 1
	li $t6, -1
	
	lb $t4, 0($t8)	#loading number of rows into $t4
	beq $t5, $t4, convertHealth	#if the number of rows is equal to row counter -> go to convertHeath
	
	readMapInnerLoop:
		addi $t6, $t6, 1
			#Iterate through MAP_DATA in the file
			move $a0, $t0
			move $a2, $sp
			li $a2, 1
			li $v0, 14
			syscall
			lbu $t2, 0($sp)
		
		beq $t2, 10, readMapOuterLoop	#found new line
		beq $t2, 64, foundPlayer
		
		ori $t2, $t2, 0x80
		sb $t2, 0($t1)
		addi $t1, $t1, 1
		j readMapInnerLoop
			
		
		foundPlayer:
		sb $t5, 0($t9)
		sb $t6, 1($t9)
		
		ori $t2, $t2, 0x80	#set byte to hidden
		sb $t2, 0($t1)
		addi $t1, $t1, 1
		j readMapInnerLoop
	

convertHealth:
	move $a0, $t0
	move $a2, $sp
	li $a2, 1
	li $v0, 14
	syscall
	lbu $t2, 0($sp)
	
	li $t3, 10		#subtract 48 and multiply 10 (get the Tens place)
	addi $t2, $t2, -48
	mul $t4, $t2, $t3
	
	move $a0, $t0
	move $a2, $sp
	li $a2, 1
	li $v0, 14
	syscall
	
	lbu $t2, 0($sp)
	addi $t2, $t2, -48
	add $t4, $t4, $t2
	sb $t4, 2($t9)
	
	li $t4, 0
	sb $t4, 3($t9)
	
	#close the file
	move $a0, $t0
	li $v0, 16
	syscall
	j exitLoop
	
	
#Conver Number of rows and columns to decimal
convertRowCol:
	li $t3, 10
	addi $t2, $t2, -48
	mul $t4, $t2, $t3	#$t4 holds the tens place of the number
	j readFromFileLoop
addToTensPlace:
	addi $t2, $t2, -48
	add $t4, $t4, $t2
	beq $t1, 2, storeRow
	beq $t1, 5, storeCol
	storeRow:
		sb $t4, 0($t8)
		j readFromFileLoop
	storeCol:
		sb $t4, 1($t8)
		j readFromFileLoop
exitLoop:


returnSuccess1:
addi $sp, $sp, 1
li $v0, 0
jr $ra

returnError1:
addi $sp, $sp, 1
li $v0, -1
jr $ra


# Part II
is_valid_cell:
li $v0, -200
li $v1, -200

lb $t0, 0($a0)	#number of rows
lb $t1, 1($a0)	#number of cols

bltz $a1, returnError2
bge $a1, $t0, returnError2
bltz $a2, returnError2
bge $a2, $t1, returnError2

returnSuccess2:
li $v0, 0
jr $ra

returnError2:
li $v0, -1
jr $ra


# Part III
get_cell:
li $v0, -200
li $v1, -200

addi $sp, $sp, -16
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map 
move $s1, $a1	#row index
move $s2, $a2	#col index

#first check to see if they are valid coords
move $a0, $s0
move $a1, $s1
move $a2, $s2
jal is_valid_cell
beq $v0, -1, returnError3

lb $t1, 1($s0)			#number of cols
mul $t0, $s1, $t1 		#number of cols * row index
add $t0, $t0, $s2

addi $t0, $t0, 2
add $s0, $s0, $t0	#offset to get the cell at row index, col index
lbu $t2, 0($s0)

returnSuccess3:
move $v0, $t2
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
addi $sp, $sp, 16
jr $ra

returnError3:
li $v0, -1
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
addi $sp, $sp, 16
jr $ra


# Part IV
set_cell:
li $v0, -200
li $v1, -200


addi $sp, $sp, -20
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#row index
move $s2, $a2	#col index
move $s3, $a3	#char


#First, check to see if they are valid coords
move $a0, $s0
move $a1, $s1
move $a2, $s2
jal is_valid_cell
beq $v0, -1, returnError4

#Set the char at [i][i] to char ($s3)
lb $t0, 1($s0)		#number of cols
mul $t0, $t0, $s1
add $t0, $t0, $s2
addi $t0, $t0, 2

add $s0, $s0, $t0
sb $s3, 0($s0)


returnSuccess4:
li $v0, 0
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

returnError4:
li $v0, -1
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra


# Part V
reveal_area:
li $v0, -200
li $v1, -200

addi $sp, $sp, -32
sw $s6, 28($sp)
sw $s5, 24($sp)
sw $s4, 20($sp)
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#row index
move $s2, $a2	#col index

#Subtract 1 from row and column
li $s6, 0
addi $s1, $s1, -1
addi $s2, $s2, -1
j iterateCellInnerLoop

iterateCellOuterLoop:
	addi $s1, $s1, 1
	addi $s2, $s2, -3
	
	iterateCellInnerLoop:
		#Check each cell in the 3*3 
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		jal is_valid_cell
		beq $v0, -1, nextCell
		
		#Now call get cell to retrieve the cell at that point
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		jal get_cell
		move $t0, $v0	#value of the current cell
		andi $t0, $t0, 0x7F
		
		#Now call set_cell to input the ascii charachter to not-hidden
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $a3, $t0
		jal set_cell
		
	nextCell:
	addi $s2, $s2, 1
	addi $s6, $s6, 1
	beq $s6, 3, iterateCellOuterLoop
	beq $s6, 6, iterateCellOuterLoop
	beq $s6, 9, exitCellLoop
	j iterateCellInnerLoop
	
	
exitCellLoop:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
addi $sp, $sp, 32
jr $ra

# Part VI
get_attack_target:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $s4, 20($sp)
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#player
move $s2, $a2	#direction
lb $s3, 0($s1)	#players current row
lb $s4, 1($s1)	#players current column

beq $s2, 85, targetUp
beq $s2, 68, targetDown
beq $s2, 76, targetLeft
beq $s2, 82, targetRight
j returnError6

targetUp:
	move $a0, $s0
	addi $a1, $s3, -1
	move $a2, $s4
	jal get_cell
	beq $v0, 109, returnTarget
	beq $v0, 66, returnTarget
	beq $v0, 47, returnTarget
	j returnError6
	
targetDown:
	move $a0, $s0
	addi $a1, $s3, 1
	move $a2, $s4
	jal get_cell
	beq $v0, 109, returnTarget
	beq $v0, 66, returnTarget
	beq $v0, 47, returnTarget
	j returnError6
	
targetLeft:
	move $a0, $s0
	move $a1, $s3
	addi $a2, $s4, -1
	jal get_cell
	beq $v0, 109, returnTarget
	beq $v0, 66, returnTarget
	beq $v0, 47, returnTarget
	j returnError6
	
targetRight:
	move $a0, $s0
	move $a1, $s3
	addi $a2, $s4, 1
	jal get_cell
	beq $v0, 109, returnTarget
	beq $v0, 66, returnTarget
	beq $v0, 47, returnTarget
	j returnError6

returnTarget:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra

returnError6:
li $v0, -1
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra


# Part VII--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
complete_attack:
li $v0, -200
li $v1, -200

addi $sp, $sp, -20
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#player
move $s2, $a2	#target row	
move $s3, $a3	#target col

move $a0, $s0
move $a1, $s2
move $a2, $s3
jal get_cell
beq $v0, 109, killMinion
beq $v0, 66, killBoss
beq $v0, 47, killDoor

killMinion:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 36	#ascii value for $
	jal set_cell
	
	lb $t0, 2($s1)
	addi $t0, $t0, -1
	sb $t0, 2($s1)
	bgtz $t0, doneKilling
	
	lb $t1, 0($s1)	#current row of the player
	lb $t2, 1($s1)	#current column of the player
	move $a0, $s0	
	move $a1, $t1
	move $a2, $t2
	li $a3, 88	#ascii value for X
	j doneKilling
	
	
killBoss:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 42	#ascii value for *
	jal set_cell
	
	lb $t0, 2($s1)
	addi $t0, $t0, -2
	sb $t0, 2($s1)
	bgtz $t0, doneKilling
	
	lb $t1, 0($s1)	#current row of the player
	lb $t2, 1($s1)	#current column of the player
	move $a0, $s0	
	move $a1, $t1
	move $a2, $t2
	li $a3, 88	#ascii value for X
	j doneKilling
	

killDoor:
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 46	#ascii value for .
	jal set_cell
	j doneKilling


doneKilling:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra


# Part VIII
monster_attacks:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $s4, 20($sp)
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#player
lb $s2, 0($s1)	#player row
lb $s3, 1($s1)	#player col
li $s4, 0	#counter for potential damage

checkUp:
	move $a0, $s0
	addi $a1, $s2, -1
	move $a2, $s3
	jal get_cell
	beq $v0, 109, addOne1
	beq $v0, 66, addTwo1
	j checkDown
		addOne1:
			addi $s4, $s4, 1
			j checkDown
		addTwo1:
			addi $s4, $s4, 2
			j checkDown
		
checkDown:
	move $a0, $s0
	addi $a1, $s2, 1
	move $a2, $s3
	jal get_cell
	beq $v0, 109, addOne2
	beq $v0, 66, addTwo2
	j checkLeft
		addOne2:
			addi $s4, $s4, 1
			j checkLeft
		addTwo2:
			addi $s4, $s4, 2
			j checkLeft

checkLeft:
	move $a0, $s0
	move $a1, $s2
	addi $a2, $s3, -1
	jal get_cell
	beq $v0, 109, addOne3
	beq $v0, 66, addTwo3
	j checkRight
		addOne3:
			addi $s4, $s4, 1
			j checkRight
		addTwo3:
			addi $s4, $s4, 2
			j checkRight

checkRight:
	move $a0, $s0
	move $a1, $s2
	addi $a2, $s3, 1
	jal get_cell
	beq $v0, 109, addOne4
	beq $v0, 66, addTwo4
	j doneChecking
		addOne4:
			addi $s4, $s4, 1
			j doneChecking
		addTwo4:
			addi $s4, $s4, 2
			j doneChecking


doneChecking:
move $v0, $s4	#the sum of damage into $v0
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra


# Part IX--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
player_move:
li $v0, -200
li $v1, -200

addi $sp, $sp, -20
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map
move $s1, $a1	#player
move $s2, $a2	#target row
move $s3, $a3	#target col

#Update the health of the player
move $a0, $s0
move $a1, $s1
jal monster_attacks
li $t0, -1
mul $t0, $t0, $v0	#inverting $v0 (sum of damage)

lb $t1, 2($s1)
add $t1, $t1, $t0
sb $t1, 2($s1)

#If the healh of the player is equal to or less than zero -> return Death
blez $t1, returnDeath

#get the target cell
move $a0, $s0
move $a1, $s2
move $a2, $s3
jal get_cell

beq $v0, 46, targetIsFloor	#ascii value for .
beq $v0, 36, targetIsCoin	#ascii value for $
beq $v0, 42, targetIsGem	#ascii value for *
beq $v0, 62, targetIsDoor	#ascii value for >

targetIsFloor:
	#Set the player pos to '.'
	move $a0, $s0
	lb $a1, 0($s1)
	lb $a2, 1($s1)
	li $a3, 46
	jal set_cell
	#Set the target position to '@'
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 64
	jal set_cell
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	j returnZeroLabel
	
targetIsCoin:
	#Set the player pos to '.'
	move $a0, $s0
	lb $a1, 0($s1)
	lb $a2, 1($s1)
	li $a3, 46
	jal set_cell
	#Set the target position to '@'
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 64
	jal set_cell
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	#Add one to coins in player struct
	lb $t0, 3($s1)
	addi $t0, $t0, 1
	sb $t0, 3($s1)
	j returnZeroLabel
	
targetIsGem:
	#Set the player pos to '.'
	move $a0, $s0
	lb $a1, 0($s1)
	lb $a2, 1($s1)
	li $a3, 46
	jal set_cell
	#Set the target position to '@'
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 64
	jal set_cell
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	#Add five to coins in player struct
	lb $t0, 3($s1)
	addi $t0, $t0, 5
	sb $t0, 3($s1)
	j returnZeroLabel
	
targetIsDoor:
	#Set the player pos to '.'
	move $a0, $s0
	lb $a1, 0($s1)
	lb $a2, 1($s1)
	li $a3, 46
	jal set_cell
	sb $s2, 0($s1)
	sb $s3, 1($s1)
	#Set the target position to '@'
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	li $a3, 64
	jal set_cell
	j returnNegOneLabel


returnDeath:
move $a0, $s0
lb $a1, 0($s1)
lb $a2, 1($s1)
li $a3, 88
jal set_cell

returnZeroLabel:
li $v0, 0
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

returnNegOneLabel:
li $v0, -1
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra


# Part X--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
player_turn:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $s4, 20($sp)
sw $s3, 16($sp)
sw $s2, 12($sp)
sw $s1, 8($sp)
sw $s0, 4($sp)
sw $ra, 0($sp)

move $s0, $a0	#map 
move $s1, $a1	#player
move $s2, $a2	#Direction
lb $s3, 0($s1)	#player row
lb $s4, 1($s1)	#player col

#Check if direction is one of (U D L R)
beq $s2, 85, attemptUp
beq $s2, 68, attemptDown
beq $s2, 76, attemptLeft
beq $s2, 82, attemptRight
li $v0, -1
j endFunction10

attemptUp:
	move $a0, $s0
	addi $a1, $s3, -1	#row
	move $a2, $s4		#col
	jal get_cell
	beq $v0, -1, endFunctionWithZero
	beq $v0, 35, endFunctionWithZero
	
	#Need to check if target pos is attackable
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_attack_target
	beq $v0, -1, cannotAttack1
		#Here is where we can attack
		move $a0, $s0
		move $a1, $s1
		addi $a2, $s3, -1	#row
		move $a3, $s4		#col
		jal complete_attack			
		j endFunctionWithZero
		
		cannotAttack1:
		move $a0, $s0
		move $a1, $s1
		addi $a2, $s3, -1	#row
		move $a3, $s4		#col
		jal player_move
		j endFunction10
		
attemptDown:	
	move $a0, $s0
	addi $a1, $s3, 1	#row
	move $a2, $s4		#col
	jal get_cell
	beq $v0, -1, endFunctionWithZero
	beq $v0, 35, endFunctionWithZero	#door value
	
	#Need to check if target pos is attackable
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_attack_target
	beq $v0, -1, cannotAttack2
		#Here is where we can attack
		move $a0, $s0
		move $a1, $s1
		addi $a2, $s3, 1	#row
		move $a3, $s4		#col
		jal complete_attack			
		j endFunctionWithZero
		
		cannotAttack2:
		move $a0, $s0
		move $a1, $s1
		addi $a2, $s3, 1	#row
		move $a3, $s4		#col
		jal player_move
		j endFunction10

	
attemptLeft:
	move $a0, $s0
	move $a1, $s3		#row
	addi $a2, $s4, -1	#col
	jal get_cell
	beq $v0, -1, endFunctionWithZero
	beq $v0, 35, endFunctionWithZero	#door value
	
	#Need to check if target pos is attackable
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_attack_target
	beq $v0, -1, cannotAttack3
		#Here is where we can attack
		move $a0, $s0
		move $a1, $s1
		move $a2, $s3	 		#row
		addi $a3, $s4, -1		#col
		jal complete_attack			
		j endFunctionWithZero
		
		cannotAttack3:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s3		#row
		addi $a3, $s4, -1		#col
		jal player_move
		j endFunction10
	
attemptRight:
	move $a0, $s0
	move $a1, $s3		#row
	addi $a2, $s4, 1	#col
	jal get_cell
	beq $v0, -1, endFunctionWithZero
	beq $v0, 35, endFunctionWithZero	#door value
	
	#Need to check if target pos is attackable
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal get_attack_target
	beq $v0, -1, cannotAttack4
		#Here is where we can attack
		move $a0, $s0
		move $a1, $s1
		move $a2, $s3	 		#row
		addi $a3, $s4, 1		#col
		jal complete_attack			
		j endFunctionWithZero
		
		cannotAttack4:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s3			#row
		addi $a3, $s4, 1		#col
		jal player_move
		j endFunction10
	

endFunctionWithZero:
li $v0, 0	
endFunction10:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra


# Part XI
flood_fill_reveal:
li $v0, -200
li $v1, -200
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
