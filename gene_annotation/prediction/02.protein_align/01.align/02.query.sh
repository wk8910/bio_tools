cat ../00.protein/*.pep > query.pep
~/bio_tools/00.scripts/fasta-splitter.pl --n-parts 100 query.pep --out-dir query
