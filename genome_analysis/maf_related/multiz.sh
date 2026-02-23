/public/home/wangkun/software/last/last-1254/bin/lastdb ref_001 chr001.fa
/public/home/wangkun/software/last/last-1254/bin/lastal -P 64 ref_001 chr002.fa > aln_2to1.maf
/public/home/wangkun/software/last/last-1254/bin/lastal -P 64 ref_001 chr003.fa > aln_3to1.maf
~/software/last/last-1254/bin/last-split aln_2to1.maf > aln_2to1.single.maf
~/software/last/last-1254/bin/last-split aln_2to1.maf > aln_3to1.single.maf
perl rename.pl aln_2to1.single.maf c1 c2 > c1.c2.sing.maf
perl rename.pl aln_2to1.single.maf c1 c3 > c1.c3.sing.maf
~/software/alignment/multiz-tba.012109-build/roast - T=. E=c1 "((c1 c3) c2)" c1.c2.sing.maf c1.c3.sing.maf c1.maf > roast.sh
export PATH=$PATH:/public/home/wangkun/software/alignment/multiz-tba.012109-build
sh roast.sh
