.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 	# 512 wide X 256 high pixels
w: .word 100 			# width of flask is 100
h: .word 40 			# height is 70
l: .word 40 			# L is 80
chr: .word 0x00 		# red color component of house
chg: .word 0x00 		# blue color component of house
chb: .word 0xFF 		# green color component of house
cdr: .word 0x96 		# red color component of house
cdg: .word 0x4B 		# blue color component of house
cdb: .word 0x00 		# green color component of house
bgcol: .word 0x00406080
testcol: .word  0x00FFFF00 	#test color for pixels

# DONOTMODIFYTHISLINE
.text
# load w, h, d
lw $s0, w 			# s0 <- w
lw $s1, l 			# s1 <- l
lw $s2, h			# s2 <- h
srl $s3, $s0, 1 		# s3 = s0 / 2 (THIS IS W/2, HEIGHT FOR TRIANGLE)
srl $s4, $s1, 1 		# s4 = s1 / 2 (THIS IS H/2, HEIGHT FOR DOOR)
lw $s5, bgcol			# s5 <- background_color
lw $s6, testcol
la $t0, frameBuffer 		# t0 <- frameBuffer
li $t1, 0x20000 		# t1 <- total number of pixels (512*256)

###-------BACKGROUND-------
fillBG:
sw $s5, 0($t0) 			# current pixel is yellow (Mem[t0] <- t2)
addi $t0, $t0, 4 		# t0 <- t0 + 4 (move to next pixel)
addi $t1, $t1, -1 		# t1 <- t1 - 1 (subtract count of total number of pizels)
bne $t1, $zero, fillBG		# keep drawing each line for background

###------CHECK FOR INVALID CONDITIONS------
blt $s0, $s2, Exit 		# if s0 (w) is less than s2 (d), go to Exit
#Check if width and heigth and door are odd
andi $t0, $s0, 1 		# see if rightmost bit of w is 0 or 1
bne $t0, $zero, Exit 		# if t0 (w) is odd, go to Exit
andi $t0, $s1, 1		# see if rightmost bit of h is 0 or 1
bne $t0, $zero, Exit 		# if t0 (h) is odd, go to Exit
andi $t0, $s2, 1		# see if rightmost bit of d is 0 or 1
bne $t0, $zero, Exit 		# if t0 (d) is odd, go to Exit
#Check if width and height are positive and in bounds
blt $s0, $zero, Exit 		# s0 < 0, go to Exit
blt $s1, $zero, Exit 		# s1 < 0, go to Exit
blt $s2, $zero, Exit 		# s2 < 0, go to Exit
li $t2, 512 			# t2 <- 512
blt $t2, $s0, Exit  		# t2 < s0, go to Exit (512 < w)
add $t1, $s1, $s3 		# t1 = s1 + s3 (h + w/2)
li $t2, 256 			# t2 <- 256
blt $t2, $t1, Exit		# t2 < t1, go to Exit
# Check if rgb values greater than 255 or less than 0
li $t3, 256			# t3 <- 256
##Color ch
#chr
lw $t4, chr			# t4 <- chr
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
#chg
lw $t4, chg			# t4 <- chg
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
#chb
lw $t4, chb			# t4 <- chb
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
##Color cd
#cdr
lw $t4, cdr			# t4 <- cdr
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
lw $t4, cdg			# t4 <- cdg
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
lw $t4, cdb			# t4 <- cdb
blt $t4, 0, Exit		# t4 < 0, go to Exit
blt $t3, $t4, Exit		# t3 < t4, go to Exit
##Build colors
#Color ch
lw $t3, chr 			# t3 <- chr
sll $t3, $t3, 8 		# shift t4 8 bits left
lw $t4, chg 			# t4 <- chg
add $t3, $t3, $t4               # t4 = t4 + t3
sll $t3, $t3, 8 		# shift t3 8 bits left
lw $t4, chb			# t4 <- cgb
add $t3, $t3, $t4 		# t3 = t3 + t4 (t3 stores color of ch)
#Color cd
lw $t4, cdr 			# t4 <- cdr
sll $t4, $t4, 8 		# shift t4 8 bits left
lw $t5, cdg 			# t5 <- cdg
add $t4, $t4, $t5               # t4 = t4 + t5
sll $t4, $t4, 8 		# shift t4 8 bits left
lw $t5, cdb			# t5 <- cdb
add $t4, $t4, $t5 		# t4 = t4 + t5 (t4 stores color of cd)

###Drawing Shapes
#t3 is color for L part of flask (BLUE)
#t4 is color for door, triangle (BROWN)
#LEFT BODY OF FLASK --> L
PreCondLBoxLeft:
la $t0, frameBuffer 		# t0 <- frameBuffer
sub $t1, $s3, 0			# t1 <- s3   (w/2)
li $t5, 0 			# t5 <- 0 (Counter for height)
add $t6, $zero, 523260		# t6 <- left bottommost center pixel
add $t0, $t0, $t6		# index of t0 is 523260
LBoxLeftBlue:				
sw $t3,($t0) 			# current pixel is blue (Mem[] <- t3) center left
sub $t0, $t0, 4 		# t0 <- t0 - 4 (move to next left pixel)
sub $t1, $t1, 1 		# t1 <- t1 - 1 (subtract count of total number of pizels)
bne $t1, $zero, LBoxLeftBlue 	# go to LBlue if t1 != 0
addi $t5, $t5, 1 		# add to height count 
bne $t5, $s1, LBoxLeftHtCond	# when height counter isnt equal to height go to LCondition
beq $t5, $s1, PreCondLBoxRight	# move on to next function if t5 = s1
LBoxLeftHtCond:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t6, $t6, 2048		# move a pixel up and store in t6
add $t0, $t0, $t6		# add new index to frameBuffer
sub $t1, $s3, 0 		# t1 <- s3 (w/2)
j LBoxLeftBlue                  # jump back up to LBlue

#RIGHT BODY OF FLASK --> L
PreCondLBoxRight:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t1, $s3, 0			# t1 <- s3 (w/2)
li $t5, 0 			# t5 <- 0 (Counter for height)
add $t6, $zero, 523264		# t6 <- right bottommost center pixel
add $t0, $t0, $t6		# frameBuffer index set to t6
LBoxRightBlue:
sw $t3,($t0)			# current pixel is blue (Mem[] <- t3) center left
add $t0, $t0, 4			# t0 <- t0 + 4 (move to next right pixel)
sub $t1, $t1, 1			# t1 <- t1 - 1 (subtract count of total number of pizels)
bne $t1, $zero, LBoxRightBlue	# t1 (w/2) != 0, keep looping
addi $t5, $t5, 1 		# add to height count
bne $t5, $s1, LBoxRightHtCond	# when height counter isnt equal to height go to RCondition
beq $t5, $s1, PreCondHBoxLeft	# move on to PreCOndDL
LBoxRightHtCond:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t6, $t6, 2048		# move a pixel up and store in t6
add $t0, $t0, $t6		# add new index to frameBuffer
sub $t1, $s3, 0 		# t1 <- s3 (w/2)
j LBoxRightBlue			# jump back up to RBlue

#LEFT BODY OF FLASK --> H
PreCondHBoxLeft:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t1, $s3, 0			# t1 <- s3 (w/2)
li $t5, 0 			# t5 <- 0 (Counter for height)
add $t7, $zero, 523260		# t7 <- left bottommost center pixel
add $t6, $s1, 0			# t6 = height of box L
sll $t6, $t6, 11		# t6 * 2048
sub $t6, $t7, $t6		# t6 <- t7 - t6
add $t0, $t0, $t6		# frameBuffer index set to t6
li $t7, 0			# t7 = 0
HBoxLeftYellow:
sw $s6,($t0)			# current pixel is yellow (Mem[] <- t3) center left
sub $t0, $t0, 4			# t0 <- t0 + 4 (move to next right pixel)
sub $t1, $t1, 1			# t1 <- t1 - 1 (subtract count of total number of pizels)
bne $t1, $zero, HBoxLeftYellow	# t1 (w/2) != 0, keep looping
addi $t5, $t5, 1 		# add to height count
bne $t5, $s1, HBoxLeftHtCond	# when height counter isnt equal to height go to RCondition
beq $t5, $s1, PreCondHBoxRight	# move on to PreCOndDL
HBoxLeftHtCond:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t6, $t6, 2048		# move a pixel up and store in t6
add $t0, $t0, $t6		# add new index to frameBuffer
sub $t1, $s3, 0 		# t1 <- s3 (w/2)
j HBoxLeftYellow		# jump back up to RBlue

#RIGHT BODY OF FLASK --> H
PreCondHBoxRight:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t1, $s3, 0			# t1 <- s3 (w/2)
li $t5, 0 			# t5 <- 0 (Counter for height)
add $t7, $zero, 523264		# t7 <- right bottommost center pixel
add $t6, $s1, 0			# t6 = height of box L
sll $t6, $t6, 11		# t6 * 2048
sub $t6, $t7, $t6		# t6 <- t7 - t6
add $t0, $t0, $t6		# frameBuffer index set to t6
li $t7, 0			# t7 = 0
HBoxRightYellow:
sw $s6,($t0)			# current pixel is yellow (Mem[] <- t3) center left
add $t0, $t0, 4			# t0 <- t0 + 4 (move to next right pixel)
sub $t1, $t1, 1			# t1 <- t1 - 1 (subtract count of total number of pizels)
bne $t1, $zero, HBoxRightYellow	# t1 (w/2) != 0, keep looping
addi $t5, $t5, 1 		# add to height count
bne $t5, $s1, HBoxRightHtCond	# when height counter isnt equal to height go to RCondition
beq $t5, $s1, Exit		# move on to PreCOndDL
HBoxRightHtCond:
la $t0, frameBuffer		# t0 <- frameBuffer
sub $t6, $t6, 2048		# move a pixel up and store in t6
add $t0, $t0, $t6		# add new index to frameBuffer
sub $t1, $s3, 0 		# t1 <- s3 (w/2)
j HBoxRightYellow		# jump back up to RBlue


Exit:
li $v0,10 			# exit code
syscall 			# exit to OS
