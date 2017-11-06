
lui $a0, 0x4049
addi $t0, $zero, 0xfd8
add $a0, $a0, $t0	#a0 = 3.141592 

lui $a1, 0x402d
addi $t0, $zero, 0xf851
add $a1, $a1, $t0	#a1 = 2.718281

lui $s0, 0x08000		#sign mask
lui $s1, 0x07f80		#power mask
lui $s2, 0x07f		#fraction mask, high part
addi $t0,$zero, 0x0ffff	
add $s2,$s2,$t0		#fraction mask, low part
#-------------------------------------------------------
#-----------------------apply masks for calculations
and $t9,$s0,$a0		#sign of n1
and $t8,$s0,$a1		#sign of n2

and $t7,$s1,$a0		#power of n1
and $t6,$s1,$a1		#power of n2

and $t5,$s2,$a0		#fraction of n1
and $t4,$s2,$a1		#fraction of n2
#-------------------------------------------------------
#-----------------------power calculations
sub $s6, $t7,$t6	#(exp n1)-(exp n2)
beq $s6, $zero,zero	#(exp n1)-(exp n2)=0
slt $v0, $s6, $zero 	#if n2>n1 v0=1
beq $v0, $zero,alternate#if n1>n2 v0=1
#-----------------------n2>n1
sub $v1, $t6, $t7	#(exp n2)-(exp n1)=v1
add $a2, $v1, $zero	#shif number
add $a3, $zero, $t4	#fraction to shift (n2)
add $a1,$zero,$t5	#a1 and a2 as fraction parameters for addition
#--------------------------------------------------------
#-----------------------shift left a2 number a3 times
shiftnumber:
	shiftloop:
			sll $a3, $a3,1
			subi $a2,$a2,1
			bne $a2,$zero,shiftloop
#--------------------------------------------------------
#-----------------------add to fractions			
addfractions:
		add $v0,$a2,$a1
		and $t0,$s2,$v0		#fraction addition result with mask
		j final		
#----------------------check if #(exp n2)-(exp n1)=0
zero:		
		add $a2,$zero,$t5
		add $a1,$zero,$t4
		lui $a0,0x80
		j addfractions
#--------------------------------------------------------
alternate:	sub $v1, $t7,$t6	#(exp n1)-(exp n2)
		add $a2, $v1, $zero	#shif number
		add $a3, $zero, $t5	#fraction to shift (n1)
		add $a1,$zero,$t4	#a1 and a2 as fraction parameters for addition
		j shiftnumber
#--------------------------------------------------------
final:
		and $t1, $t9,$t8
		add $v0,$zero,$t1	#sign
		lui $t1,0x3f80
		add $v1, $v1,$t1
		add $v1, $v1,$a0
		and $v1,$v1,$s1
		add $v0,$v0,$v1		#power
		add $v0,$v0,$t0		#fraction
exit: