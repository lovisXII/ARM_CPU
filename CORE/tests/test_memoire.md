add r3, r3, 3 
1110- 00 1 0-100 0 -0011 -0011 -0000-0000-0011
E2833003


1110 01 0 0 1 1 0 0 0010 0011 0000 00000111
1110 0100 1100 0010 0011 0001 0000 0101
SB R3, [R2, #6]
E4C23106
valeur de r2 + #6
r3 <- MEM{r2+#6}



1110 01 0 0 1 1 1 1 0010 0011 0001 00000101
1110 0100 1101 0010 0011 0001 0000 0101
LB R3, [R2, #6]!
E4D23106
valeur de r2 + #6
r3 <- MEM{r2+#6}


