// A function that implements the quicksort algorithm.
// Running time complexity:  amortised O(nlogn worst case: O(n^2
// Running space complexity: O(nlogn worst case: O(n
//
// quicksort(int arr[] int start int end
// Requires: 'start' >= 0
//           'end' < length(arr

:MAIN
lui sp 0xf0

addi a1 x0 .basePointer // start
addi a2 x0 .arrayEnd // end

jal ra :QUICKSORT
nop
jal ra :EXIT
nop

:QUICKSORT
addi sp sp -20
sw ra sp 16
sw s3 sp 12
sw s2 sp 8
sw s1 sp 4
sw s0 sp 0

addi s0 a0 0
addi s1 a1 0
addi s2 a2 0
BLT a2 a1 :START_GT_END
nop

jal ra :PARTITION
nop

addi s3 a0 0   // pi

addi a0 s0 0
addi a1 s1 0
addi a2 s3 -1
jal ra :QUICKSORT  // quicksort(arr start pi - 1;
nop

addi a0 s0 0
addi a1 s3 1
addi a2 s2 0
jal ra :QUICKSORT  // quicksort(arr pi + 1 end;
nop

:START_GT_END

lw s0 sp 0
lw s1 sp 4
lw s2 sp 8
lw s3 sp 12
lw ra sp 16
addi sp sp 20
jalr x0 ra 0
nop

:PARTITION
addi sp sp -4
sw ra sp 0

slli t0 a2 2   // end * sizeof(int
add t0 t0 a0  
lw t0 t0 0    // pivot = arr[end]
addi t1 a1 -1  // i = (start - 1

addi t2 a1 0   // j = start
:LOOP
BEQ t2 a2 :LOOP_DONE   // while (j < end
nop

slli t3 t2 2   // j * sizeof(int
add a6 t3 a0   // (arr + j
lw t3 a6 0    // arr[j]

addi t0 t0 1   // pivot + 1
BLT t0 t3 :CURR_ELEMENT_GTE_PIVOT  // if (pivot <= arr[j]
nop
addi t1 t1 1   // i++

slli t5 t1 2   // i * sizeof(int
add a7 t5 a0   // (arr + i
lw t5 a7 0    // arr[i]

sw t3 a7 0    // swap(&arr[i] &arr[j]
sw t5 a6 0

:CURR_ELEMENT_GTE_PIVOT
addi t2 t2 1   // j++
beq x0 x0 :LOOP
nop
:LOOP_DONE

addi t5 t1 1   // i + 1
addi a5 t5 0   // Save for return value.
slli t5 t5 2   // (i + 1 * sizeof(int
add a7 t5 a0   // (arr + (i + 1
lw t5 a7 0     // arr[i + 1]

slli t3 a2 2   // end * sizeof(int
add a6 t3 a0   // (arr + end
lw t3 a6 0     // arr[end]

sw t5 a6 0	   // swap(&arr[i + 1] &arr[end]
sw t3 a7 0     


addi a0 a5 0   // return i + 1

lw ra sp 0
addi sp sp 4
jalr x0 ra 0

:EXIT
jump 0
nop

.word basePointer :arrayStart
.word arrayEnd :arrayEnd

.word padding0 0x00000000
.word padding1 0x00000000
.word padding2 0x00000000

:arrayStart
.word element0 0xA1B2C3D4
.word element1 0x1E2F3A4B
.word element2 0x4C5D6E7F
.word element3 0xF0E1D2C3
//.word element4 0x7A8B9C0D
//.word element5 0x12345678
//.word element6 0x9ABCDEF0
//.word element7 0x0FEDCBA9
//.word element8 0x89ABCDEF
//.word element9 0x76543210
//.word element10 0xBA98DCFE
//.word element11 0x13579BDF
//.word element12 0x2468ACE0
//.word element13 0xACE1B2D3
//.word element14 0xB1C2D3E4
//.word element15 0xC0F1E2D3
//.word element16 0xD4E5F6A7
//.word element17 0xE6F7A8B9
//.word element18 0xF8A9B0C1
//.word element19 0xA0B1C2D3
//.word element20 0x1234ABCD
//.word element21 0x0A1B2C3D
//.word element22 0xFEDCBA98
//.word element23 0x7654FEDC
//.word element24 0x89ABCDE0
//.word element25 0x56789ABC
//.word element26 0x1D2C3B4A
//.word element27 0x2E3D4A5B
//.word element28 0x3F4A5B6C
//.word element29 0x4E5F6A7B
//.word element30 0x5A6B7C8D
:arrayEnd
.word element31 0x6C7D8E9F
