cat ../02.protein_align/01.align/09.combine.pl.psl ../03.trans_align/01.align/09.combine.pl.psl > protein_trans.psl
cat ../02.protein_align/01.align/query.pep ../03.trans_align/01.align/query.pep > all.query
# ln -s ../00.genome/sterlet.fa .
# perl sub.split_genome.pl sterlet.fa
