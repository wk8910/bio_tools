export PATH=$PATH:/home/share/software/saguarogw/saguarogw-code/
VCF2HMMFeature -i version0911.snpEff.vcf -o bovine.feature -m 5 -nosame > convert.log
Saguaro -f bovine.feature -o saguaro_out -iter 10 > saguaro.out
