.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
w: .word 80
h: .word 40  
l: .word 60
bgcol: .word 0x00E2CD9F
# DONOTMODIFYTHISLINE
# Your variables go BELOW here only (and above .text)
blue: 	.word 0x000000FF

.text
la $t0, frameBuffer             # loads address of frameBuffer
li $t1, 0x20000 		# t1 <- total number of pixels (512*256)	
lw $s0, bgcol                   # t1 <- background color 
lw $s1, w
lw $s2, h
lw $s3, l

##################
### BACKGROUND ###
##################

drawBackground:	
sw $s0, 0($t0)			# current pixel is yellow (Mem[t0] <- t2)
addi $t0, $t0, 4		# t0 <- t0 + 4 (move to next pixel)
addi $t1, $t1, -1               # t1 <- t1 - 1
bne $t1, $zero, drawBackground  # if t5 != t2, drawBackground else continue

#############################
### CHECK CONDITIONS HERE ###
#############################

##Check if width is odd##
andi $t1, $s1, 1		#check if rightmost bit of w is 0 or 1
bne $t1, $zero, Exit		#if t1 is odd, go to Exit

##Check if l and h have uneven parity##
andi $t1, $s2, 1		#check if rightmost bit of h is 1
andi $t2, $s3, 1		#check if rightmost bit of l is 1
bne $t1, $t2, Exit		#if l-parity != h-parity, go to Exit

##Check if w < 60##
li $t1, 60			#t1 <- 60 (minimum flask width)
blt $s1, $t1, Exit 		#if w < 60, go to Exit

##Check if vars exceed max height of frame##
##64 + h + l + (w-48) / 2 <= 256##
li $t1, 64            		#t1 <- 64 (height of cap and neck)
add $t1, $t1, $s2        	#t1 <- 64 + h
add $t1, $t1, $s3        	#t1 <- 64 + h + l
addi $t2, $s1, -48       	#t2 <- w - 48 (height of the triangle)
srl $t2, $t2, 1			#t2 <- t2 / 2
add $t1, $t1, $t2       	#t1 <- 64 + h + l + ((w-48) / 2)
li $t2, 256           		#t2 <- 256 (max height of frame)
blt $t2, $t1, Exit        	#if t2 < t1, go to Exit

##Check if width and heigth are positive##
ble $s1, $zero, Exit 		#w <= 0, go to Exit
ble $s2, $zero, Exit 		#h <= 0, go to Exit
ble $s3, $zero, Exit		#l <= 0, go to Exit

##Check if width < 256 and height < 512##
li $t1, 512			#t1 <- 512 (max width of frame)
blt $t1, $s1, Exit		#t1 < w, go to Exit
li $t1, 256 			#t2 <- 256 (max height of the frame)
blt $t1, $s2, Exit		#t1 < h, go to Exit
blt $t1, $s3, Exit		#t1 < l, go to Exit

###############################################
### CALCULATING HEIGHT OFFSET FOR CENTERING ###
###############################################
#centering: (256 - (32+32+h+l+((w-48)/2)) / 2

li $s7, 0			# s7 <- 0 (counter for height)
li $t1, 64            		#t1 <- 64 (height of cap and neck)
add $t1, $t1, $s2        	#t1 <- 64 + h
add $t1, $t1, $s3        	#t1 <- 64 + h + l
addi $t2, $s1, -48       	#t2 <- w - 48 (height of the angled triangles)
srl $t2, $t2, 1			#t2 <- t2 / 2 (height of one of the triangles)
add $t1, $t1, $t2       	#t1 <- 64 + h + l + ((w-48) / 2)
li $t2, 256           		#t2 <- 256 (max height of frame)
sub $t2, $t2, $t1 		#t2 <- 256 - (64 + h + l + ((w-48) / 2))
srl $t2, $t2, 1			#t2 <- (256 - (64 + h + l + ((w-48)/2))) / 2
add $s7, $s7, $t2		#s7 <- t2 (height offset for centering)

############################
### START DRAWING SHAPES ###
############################

drawFlaskCap:	la $t0, frameBuffer 	        # t0 <- address of frameBuffer 
            	lw $t1, blue 		        # t1 <- blue 
            
            	#--Calculating Offset--
            	#Width Offset
            	#half width - 30 is the start of the drawing of cap
            	#width offset = (width / 2) - 30	
            	li $t2, 512			# t2 <- frame width 
            	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word
            	addi $t3, $zero, 30		# t3 <- 30 - half width of the cap
            	sll $t3, $t3, 2			# t3 <- 30 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- frame width / 2 - offset [WIDTH OFFSET]
            	add $t0, $t0, $t2		# frameBuffer[width offset]
            	
            	#Height Offset
            	#height offset = heightCounter * 512 (# of pixels) * 4 (# of words)
            	add $t3, $s7, $zero		# t3 <- height offset
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -- height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word) [HEIGHT OFFSET]
            	add $t0, $t0, $t3		# t0 <- frameBuffer[width offset + height offset]
            	
            	li $t2, 0			# t2 <- 0 (row) 

drawCapCol:	li $t3, 0		    	# t3 <- 0 (col)
drawCapRow:	sw $t1, 0($t0)			# t0 <- store color blue
		addi $t0, $t0, 4	        # move 1 pixel right
		addi $t3, $t3, 1	        # t3 <- t3 + 1  | counter for moving right 1 col
		bne $t3, 60, drawCapRow   	# if t3 != 60 (max width of cap)  branch to drawCapRow; else move on
		addi $t0, $t0, 1808		# (512 * 4) goes to the next line - (60 * 4) for beginning width of cap
		addi $t2, $t2, 1	        # t2 <- t2 + 1 | counter for moving down 1 row
		addi $s7, $s7, 1		# s7 <- s7 + 1 (height counter)
		bne $t2, 32, drawCapCol   	# if t2 != 32 (max height of cap) branch to drawCapCol; else move on
		
drawFlaskNeck: 	la $t0, frameBuffer		# t0 <- address of frameBuffer | reset framebuffer

		#--Calculating Color--
		#bgcol / 2 
		lw $t1, bgcol			# t1 <- bgcol
		srl $t1, $t1, 1			# t1 <- bgcol / 2
		
		#--Calculating Offset--
		#Width Offset
		#half of frame width (width / 2) - the half the neck width (24)
		#width offset = (width / 2) - 24
		li $t2, 512			# t2 <- width 
            	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word
            	addi $t3, $zero, 24		# t3 <- 24 width of neck
            	sll $t3, $t3, 2			# t3 <- 24 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset [WIDTH OFFSET]
            	add $t0, $t0, $t2		# frameBuffer[width offset]
            	
            	#Height Offset
            	#height offset = heightCounter * 512 (# of pixels) * 4 (# of words)
            	add $t3, $zero, $s7		# t3 <- height offset
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -- height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word) [HEIGHT OFFSET]
            	add $t0, $t0, $t3		# t0 <- frameBuffer[width offset + height offset]
            	
            	li $t2, 0			# t2 <- 0 (row) 
            	
drawNeckCol:	li $t3, 0			# t3 <- 0 (col)
drawNeckRow:	sw $t1, 0($t0)			# t0 <- store color bgcol/2
		addi $t0, $t0, 4	        # move 1 pixel right
		addi $t3, $t3, 1	        # t3 <- t3 + 1  | counter for moving right
		bne $t3, 48, drawNeckRow   	# if t3 != 48 (width of neck) branch to drawNeckRow; else move on
		addi $t0, $t0, 1856		# (512 * 4) goes to the next line - (48 * 4) for beginning width of neck
		addi $t2, $t2, 1	        # t2 <- t2 + 1
		addi $s7, $s7, 1		# s7 <- s7 + 1 (height counter)
		bne $t2, 32, drawNeckCol   	# if t2 != 32 (heigh of neck) repeat drawBotOuter; else move on

drawFlaskAngle:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		#--Calculating Color--
		#bgcol / 2 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 1			# t2 <- bgcol / 2
		
		##--Calculating Offset---
		#Width Offset
		#half of frame width (width / 2) - the half the neck width (24)
		#width offset = (width / 2) - 24
		#add pixels on line after flask neck 
		li $t2, 512			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	addi $t3, $zero, 24		# t3 <- 48/2 width of neck
            	sll $t3, $t3, 2			# t3 <- 24 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset [WIDTH OFFSET]
            	add $t0, $t0, $t2		# t0 <- frameBuffer[width offset]
            	
            	#Height Offset
            	##height offset = heightCounter * 512 (# of pixels) * 4 (# of words)
            	add $t3, $zero, $s7		# t3 <- height offset
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -- height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word) [HEIGHT OFFSET]
            	add $t0, $t0, $t3		# t0 <- frameBuffer[width offset + height offset]
            	
            	#Stop Conditions
		lw $t2, w			# t2 <- w (max width of flask body)
		li $t3, 1860			# (512*4) - (48*4) + 4 -> offset for next line
		li $t4, 46			# t4 <- 48 - 2 (start size)
            	
drawAngleCol:	li $t6, 0			# t6 <- 0 (col) 
		addi $t3, $t3, -8		# t3 <- offset - 8 (start 1 pixel to the left for next line)
		addi $t4, $t4, 2		# t4 <- t4 + 2	(increase the width of line by 2 -> 1 on each side)	
		
drawAngleRow:	sw $t1, 0($t0)			# t0 <- store color bgcol/2
		addi $t0, $t0, 4	        # move 1 pixel right
		addi $t6, $t6, 1	        # t0 <- t0 + 1  | counter for moving right
		bne $t6, $t4, drawAngleRow   	# if t6 != t4 (max width of flask angled body) branch to drawAngleCol; else move on
		add $t0, $t0, $t3		# move to next line
		addi $s7, $s7, 1		# s7 <- s7 + 1 (height counter)
		bne $t6, $t2, drawAngleCol   	# if t6 != t2 (max height of flask angled body) branch to drawAngleRow; else move on
		
drawFlaskBody:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		#--Calculating Color--
		# bgcol / 2 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 1			# t2 <- bgcol / 2
		
		#--Calculating Offset
		#Width Offset
		#width offset = width/2 - 1/2 (flask width)
		li $t2, 512			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 1			# t3 <- w * 2 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset [WIDTH OFFSET]
            	add $t0, $t0, $t2		# t0 <- frameBuffer[width offset]
            	
            	#Height Offset
            	add $t3, $zero, $s7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[offset + height offset]
            	
            	li $t5, 0			# t5 <- 0 (row)	
            	
            	#t3 <- offset for next line [512*4 - w*4]
            	li $t2, 512			# t2 <- width 
            	sll $t2, $t2, 2			# t2 <- width * 4
            	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 2			# t3 <- w * 4
            	sub $t3, $t2, $t3		# t3 <- (frame width) * 4 - (w) * 4
            	
            	#Stop Conditions
            	lw $t2, w			# t2 <- w (width of flask)
            	lw $t4, h			# t4 <- h (height of flask body above liquid)
           
drawBodyCol:	li $t6, 0			# t6 <- 0 (col)
drawBodyRow:	sw $t1, 0($t0)			# t0 <- stores bgcol/2
		addi $t0, $t0, 4		# move 1 pixel right
		addi $t6, $t6, 1		# t6 <- t6 + 1
		bne $t6, $t2, drawBodyRow   	# if counter != w (max width of flask) branch to drawAbvInner else move on
		add $t0, $t0, $t3		# move onto next line
		addi $t5, $t5, 1	        # t5 <- t6 + 1
		addi $s7, $s7, 1		# s7 <- s7 + 1 (height counter)
		bne $t5, $t4, drawBodyCol  	# if row != height (max height of body above liquid) branch to drawAbvOuter else move on
		
drawLiquid:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		#--Calculating Color--
		# 0x00ABCDEF -> 0x00EFCDAB
		lw $t1, bgcol			# t2 <- bgcol
		andi $t2, $t1, 0x00FF0000	# t1 <- 0x00__0000 clear all except bits 23-16
		andi $t3, $t1, 0x0000FF00	# t1 <- 0x0000__00 clear all except bits 15-8
		andi $t4, $t1, 0x000000FF	# t1 <- 0x000000__ clear all except bits 7-0
		srl $t2, $t2, 16		# t2 <- shift bits right 23-16 by 16 bits to 7-0
		sll $t4, $t4, 16		# t4 <- shift bits left 7-0 by 16 bits to 23-16
		add $t1, $t2, $t3		# t1 <- add t2 and t3
		add $t1, $t1, $t4		# t1 <- add t1 and t4
		
		#--Calculating Offset
		#Width Offset
		#width offset = width/2 - 1/2 (flask width)
		li $t2, 512			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 1			# t3 <- w * 2 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset (start of drawing)
            	add $t0, $t0, $t2		# t0 <- frameBuffer[offset]
            	
            	#Height Offset
            	add $t3, $zero, $s7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[offset + height offset]
            	
            	li $t5, 0			# t5 <- 0 (row)	
            	
            	#t3 <- offset for next line [512*4 - w*4]
            	li $t2, 512			# t2 <- width 
            	sll $t2, $t2, 2			# t2 <- width * 4
            	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 2			# t3 <- w * 2
            	sub $t3, $t2, $t3		# t3 <- width*4 - w*4
            	
            	#Stop Conditions
            	lw $t2, w			# t2 <- w
            	lw $t4, l			# t4 <- l
           
drawLiqCol:	li $t6, 0			# t6 <- 0 (col)
drawLiqRow:	sw $t1, 0($t0)			# t0 <- stores color
		addi $t0, $t0, 4		# move offset 1 pixel right
		addi $t6, $t6, 1		# t6 <- t6 + 1
		bne $t6, $t2, drawLiqRow   	# if counter != w repeat drawLiqInner else move on
		add $t0, $t0, $t3		# move onto next line
		addi $t5, $t5, 1	        # t5 <- t6 + 1
		addi $s7, $s7, 1		# s7 <- s7 + 1 (height counter)
		bne $t5, $t4, drawLiqCol   	# if row != l repeat drawLiqOuter else move on
		
Exit:
		li $v0,10 # exit code
		syscall # exit to OS
