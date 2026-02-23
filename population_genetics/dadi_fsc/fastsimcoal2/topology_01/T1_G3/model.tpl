//Parameters for the coalescence simulation program : fsc252
4 samples to simulate :
//Population effective sizes (number of genes)
NPOP0
NPOP1
NPOP2
NPOP3
//Samples sizes and samples age
56
42
12
54
//Growth rates : negative growth implies population expansion
0
0
0
0
//Number of migration matrices : 0 implies no migration between demes
2
//Migration matrix 0
0           0	   0      M03_0
0           0	   M12_0  0
0           M21_0  0      0
M30_0       0	   0      0
//Migration matrix 1
0           0	   0    0
0           0	   0    0
0           0	   0    0
0           0	   0    0
//historical event: time, source, sink, migrants, new deme size, growth rate, migr mat index
3 historical event
T1           3	1       1	RES1    0	1
T2           2	0       1	RES2    0	1
T3           1	0       1	RES3    0	1
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per gen recomb and mut rates
FREQ 1 0 2.5e-8	 0.33
