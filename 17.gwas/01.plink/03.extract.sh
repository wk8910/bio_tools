plink --bfile plink --allow-extra-chr --indep-pairwise 10 100 0.9
plink --bfile plink --extract plink.prune.in --out prune --make-bed --allow-extra-chr
cp prune.fam prune.fam.old
