export PATH=/home/share/software/java/jdk1.8.0_05/bin/:$PATH
# java -jar /home/share/user/user101/software/beagle/beagle.27Jul16.86a.jar gt=yangshu.recode.vcf.gz out=yangshu.ibd ibd=true impute=false ibdtrim=4
java -jar /home/share/user/user101/software/beagle/beagle.27Jul16.86a.jar gt=snp.vcf.gz out=snp.ibd ibd=true impute=false ibdtrim=100 window=100000 overlap=10000 ibdlod=10
