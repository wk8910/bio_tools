my $file="plink.eigenvec.plot";

open O,"> PCA.plot.txt";
my @head=("id","pop");
for(my $i=1;$i<=20;$i++){
    my $ele="PC$i";
    push @head,$ele;
}
print O join "\t",@head,"\n";

open I,"< $file";
while(<I>){
    chomp;
    my @a=split(/\s+/);
    $a[1]=~s/\d+.*//g;
    print O join "\t",@a,"\n";
}
close I;
close O;
