plink --vcf pda_e.phase.vcf.gz --hwe 1e-3 midp --recode vcf-fid --out pda_e --allow-extra-chr
plink --vcf pda_w.phase.vcf.gz --hwe 1e-3 midp --recode vcf-fid --out pda_w --allow-extra-chr
plink --vcf pro.phase.vcf.gz --hwe 1e-3 midp --recode vcf-fid --out pro --allow-extra-chr
