nop
lw t0 zero .basePointer
lw t1 zero .arrayEnd
lui sp 0xf0				//inicializing stack pointer

mv a0 t0				//array address
sub a1 t1 t0			//array size

call :InsertionSort
jump 0 					//program end

:InsertionSort
addi t0 zero 0			//i=0

:outerLoop
inc t0 1 				//i++
mv t1 t0				//j=i

bge t0 a1 :endOuterLoop //i >= size ; return 

:innerLoop
	add t2 a0 t1		//&array + j
	lb t3 t2 -1			//array[j - 1]
	lb t4 t2 0			//array[j]
	ble t1 zero :outerLoop	//if j<=0
	ble t3 t4 :outerLoop //if array[j - 1] < array[j]

	sb t3 t2 0			//swap
	sb t4 t2 -1			//

	dec t1 1			//j--

	jal zero :innerLoop	//end inner loop

:endOuterLoop
ret

.word basePointer :arrayStart
.word arrayEnd :arrayEnd

.word padding0 0x00000000
.word padding1 0x00000000
.word padding2 0x00000000
.word padding3 0x00000000

:arrayStart
.word element0 0xAA99CC77
.word element1 0xEE33FF00
.word element2 0xDD112244
.word element3 0x8855BB66
:arrayEnd
