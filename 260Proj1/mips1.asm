.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
w: .word 80
h: .word 32  
l: .word 80
bgcol: .word 0x00E2CD9F
testcol: .word  0x00FFFF00 	#test color for pixels (yellow)
# DONOTMODIFYTHISLINE
# Your variables go BELOW here only (and above .text
blue: 	.word 0x000000FF
width: 	.word 512
height: .word 256

.text
la $t0, frameBuffer             # loads address of frameBuffer
li $t1, 0x20000 		# t1 <- total number of pixels (512*256)	
lw $s0, bgcol                   # t1 <- background color 
lw $s1, w
lw $s2, h
lw $s3, l

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
ble $s1, $t1, Exit 		#if w < 60, go to Exit

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

li $t7, 0		# t7 <- 0 (counter for height)
addi $t7, $t7, 16	# t7 <- t7 + 16

drawCap:	la $t0, frameBuffer 	        # t0 <- address of frameBuffer 
            	lw $t1, blue 		        # t1 <- blue 
            
            	#--Calculating Offset--
            	# half width - 30 is the start of the drawing of cap	
            	lw $t2, width			# t2 <- frame width 
            	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word
            	addi $t3, $zero, 30		# t3 <- 30 width of cap
            	sll $t3, $t3, 2			# t3 <- 30 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset [FRAME OFFSET]
            	#--Start Drawing--
            	add $t0, $t0, $t2		# t0 <- frameBuffer[0 + [FRAME OFFSET]]
            	li $t5, 0			# t5 <- 0 (row) 

drawCapOuter:	li $t6, 0		    	# t6 <- 0 (col)
drawCapInner:	sw $t1, 32768($t0)		# t0 <- store color blue | (16 * 512) lines down * 4 per word
		addi $t0, $t0, 4	        # move offset 1 pixel right
		addi $t6, $t6, 1	        # t0 <- t0 + 1  | counter for moving right 1 col
		bne $t6, 60, drawCapInner   	# if t5 != 60 repeat drawCapInner else move on
		addi $t0, $t0, 1808		# (512 * 4) brings to next line shift - backwards (60 * 4) for beginning
		addi $t5, $t5, 1	        # t5 <- t5 + 1 | counter for moving down 1 row
		addi $t7, $t7, 1		# t7 <- t7 + 1 (height counter)
		bne $t5, 32, drawCapOuter   	# if t6 != 32 (height) repeat drawCapOuter else move on
		
drawBotNeck: 	la $t0, frameBuffer		# t0 <- address of frameBuffer

		# color calculation bgcol / 2 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 1			# t2 <- bgcol / 2
		
		#--Calculating Offset--
		# calculate next line of starting pixel 
		# half (width / 2) - 24 (where the neck width is 48)
		# then add on position below cap 
		lw $t2, width			# t2 <- width 
            	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word
            	addi $t3, $zero, 24		# t3 <- 24 width of neck
            	sll $t3, $t3, 2			# t3 <- 24 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset [FRAME OFFSET]
            	
            	#--Start Drawing-
            	add $t0, $t0, $t2		# t0 <- frameBuffer[0 + [FRAME OFFSET]]
            	add $t3, $zero, $t7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[0 + offset + height offset]
            	li $t5, 0			# t5 <- 0 (row) 
            	
drawBotOuter:	li $t6, 0			# t6 <- 0 (col)
drawBotInner:	sw $t1, 0($t0)			# t0 <- store color bgcol/2
		addi $t0, $t0, 4	        # move offset 1 pixel right
		addi $t6, $t6, 1	        # t0 <- t0 + 1  | counter for moving right
		bne $t6, 48, drawBotInner   	# if t5 != 48 repeat drawBotInner else move on
		addi $t0, $t0, 1856
		addi $t5, $t5, 1	        # t6 <- t6 + 1
		addi $t7, $t7, 1		# t7 <- t7 + 1 (height counter)
		bne $t5, 32, drawBotOuter   	# if t6 != 32 repeat drawBotOuter else move on
		
		# add 1 on each side -> form a 45 degree angle
drawSlant:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		# color calculation bgcol / 2 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 1			# t2 <- bgcol / 2
		
		##--Calculating Offset---
		# calculate next line of starting pixel half width - 24 (neck is 48 in width), 
		#then add on position below neck 
		lw $t2, width			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	addi $t3, $zero, 24		# t3 <- 48/2 width of neck
            	sll $t3, $t3, 2			# t3 <- 24 * 4 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset (start of drawing)
            	add $t0, $t0, $t2		# t0 <- frameBuffer[offset]
            	add $t3, $zero, $t7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[offset + height offset]
            	
		# can use registers t2, t3, t4 
		lw $t2, w			# t2 <- w (will be ending of loop) 
		li $t3, 1860			# (512*4) - (48*4) + 4 -> next line from current position
		li $t4, 46			# t4 <- 48 - 2 (start size)
            	
drawSlantOuter:	li $t6, 0			# t6 <- 0 (col) 
		addi $t3, $t3, -8		# t3 <- offset - 8
		addi $t4, $t4, 2		# t4 <- t4 + 2		
		
drawSlantInner:	sw $t1, 0($t0)			# t0 <- store color bgcol/2
		addi $t0, $t0, 4	        # move offset 1 pixel right
		addi $t6, $t6, 1	        # t0 <- t0 + 1  | counter for moving right
		bne $t6, $t4, drawSlantInner   	# if t6 != t4 repeat drawSlantInner else move on
		add $t0, $t0, $t3		# move onto next line
		addi $t7, $t7, 1		# t7 <- t7 + 1 (height counter)
		bne $t6, $t2, drawSlantOuter   	# if t5 != t2 repeat drawSlantOuter else move on
		
drawAbvLiq:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		# color calculation bgcol / 2 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 1			# t2 <- bgcol / 2
		
		# calculate starting point, height + width/2 - 1/2(w)
		lw $t2, width			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 1			# t3 <- w * 2 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset (start of drawing)
            	add $t0, $t0, $t2		# t0 <- frameBuffer[offset]
            	add $t3, $zero, $t7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[offset + height offset]
            	li $t5, 0			# t5 <- 0 (row)	
            	
            	# calculate offset and set it as t3 [512*4 - w*4]
            	lw $t2, width			# t2 <- width 
            	sll $t2, $t2, 2			# t2 <- width * 4
            	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 2			# t3 <- w * 4
            	sub $t3, $t2, $t3		# t3 <- width*4 - w*4
            	lw $t2, w			# t2 <- w
            	lw $t4, h			# t4 <- h
           
drawAbvOuter:	li $t6, 0			# t6 <- 0 (col)

drawAbvInner:	sw $t1, 0($t0)			# t0 <- stores bgcol/2
		addi $t0, $t0, 4		# move offset 1 pixel right
		addi $t6, $t6, 1		# t6 <- t6 + 1
		bne $t6, $t2, drawAbvInner   	# if counter != w repeat drawAbvInner else move on
		add $t0, $t0, $t3		# move onto next line
		addi $t5, $t5, 1	        # t5 <- t6 + 1
		addi $t7, $t7, 1		# t7 <- t7 + 1 (height counter)
		bne $t5, $t4, drawAbvOuter   	# if row != height repeat drawAbvOuter else move on
		
drawLiquid:	la $t0, frameBuffer		# t0 <- address of frameBuffer
		
		# color calculation NEED TO FIX 
		lw $t1, bgcol			# t2 <- bgcol
		srl $t1, $t1, 2			# t2 <- bgcol / 2
		
		# calculate next line after top part before liquid, height * 512 * 4 + (width / 2 - offset)
		lw $t2, width			# t2 <- width 
           	sll $t2, $t2, 1			# t2 <- (t2 / 2) * 4  # width / 2 * 4 word 
          	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 1			# t3 <- w * 2 (offset)
            	sub $t2, $t2, $t3		# t2 <- width/2 - offset (start of drawing)
            	add $t0, $t0, $t2		# t0 <- frameBuffer[offset]
            	add $t3, $zero, $t7		# t3 <- height counter
            	sll $t3, $t3, 9			# t3 <- height counter * 512 -> height offset
            	sll $t3, $t3, 2			# t3 <- height offset * 4 (word)
            	add $t0, $t0, $t3		# t0 <- frameBuffer[offset + height offset]
            	li $t5, 0			# t5 <- 0 (row)	
            	
            	# calculate offset and set it as t3 [512*4 - w*4]
            	# 
            	lw $t2, width			# t2 <- width 
            	sll $t2, $t2, 2			# t2 <- width * 4
            	lw $t3, w			# t3 <- w
            	sll $t3, $t3, 2			# t3 <- w * 2
            	sub $t3, $t2, $t3		# t3 <- width*4 - w*4
            	lw $t2, w			# t2 <- w
            	lw $t4, l			# t4 <- l
           
drawLiqOuter:	li $t6, 0			# t6 <- 0 (col)

drawLiqInner:	sw $t1, 0($t0)			# t0 <- stores color
		addi $t0, $t0, 4		# move offset 1 pixel right
		addi $t6, $t6, 1		# t6 <- t6 + 1
		bne $t6, $t2, drawLiqInner   	# if counter != w repeat drawLiqInner else move on
		add $t0, $t0, $t3		# move onto next line
		addi $t5, $t5, 1	        # t5 <- t6 + 1
		addi $t7, $t7, 1		# t7 <- t7 + 1 (height counter)
		bne $t5, $t4, drawLiqOuter   	# if row != l repeat drawLiqOuter else move on
		
Exit:
		li $v0,10 # exit code
		syscall # exit to OS