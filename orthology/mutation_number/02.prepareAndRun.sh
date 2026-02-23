/home/share/user/user101/software/mafft/mafft-7.205-with-extensions/scripts/mafft  --thread 32 --globalpair --maxiterate 16 --reorder clean.fa > clean.aln.fa
/home/share/user/user101/software/raxml/standard-RAxML/raxmlHPC-PTHREADS-AVX -s clean.aln.fa -T 4 -n whole_mtGenome -f a -m GTRGAMMAI -k -x 271828 -N 100 -p 31415 -o Bubalus_bubalis,Bubalus_depressicornis,Syncerus_caffer
perl scripts/Gblocks2Paml.pl clean.aln.fa > mito.paml
cp RAxML_bestTree.whole_mtGenome mito.tre
/home/share/user/user101/software/paml/paml4.9e/bin/baseml baseml.ctl
