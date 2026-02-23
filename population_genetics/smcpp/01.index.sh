cat all79.vcf| bgzip -c > all79.vcf.gz
tabix -p vcf snp.vcf.gz
