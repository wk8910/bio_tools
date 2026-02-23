//Parameters for the coalescence simulation program : fsc252
2 samples to simulate :
//Population effective sizes (number of genes)
NPOP0_0
NPOP1_0
//Samples sizes and samples age
34
26
//Growth rates : negative growth implies population expansion
0
0
//Number of migration matrices : 0 implies no migration between demes
4
//Migration matrix 0
0      M01_0
M10_0  0
//Migration matrix 1
0      M01_1
M10_1  0
//Migration matrix 2
0      M01_2
M10_2  0
//Migration matrix 3
0           0
0           0
//historical event: time, source, sink, migrants, new deme size, growth rate, migr mat index
3 historical event
T1           1	1       1	RES1    0	1
T2           0	0       1	RES2    0	2
T3           1	0       1	RES3    0	3
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per gen recomb and mut rates
FREQ 1 0 2.5e-8	 0.33
