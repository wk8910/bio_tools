use strict;
use warnings;

my $input="00.gff.trans2gene.list";
die "Input file 00.gff.trans2gene.list can not find\nThe format is gff_file trans2gene_file gff_type\n" if (! -e "$input");

open (IN,"$input")||die"no such file: $input\n";
while (<IN>) {
    chomp;
    my @a=split(/\s+/,$_);
    my ($in,$out,$type)=@a;
    print "------  Reading $in \&\& Generating $out\n";
    open (O,">$out") ||die"no such file: $out\n";
    open (F,"$in") ||die"no such file: $in\n";
    while (<F>) {
        chomp;
        next if /^#/;
        my @a=split(/\s+/,$_);
        if ($a[2]=~/mRNA/){
            my $len=$a[4]-$a[3]+1;
            my ($trans,$gene);
            if ($type eq 'Ensembl'){
	$a[8]=~/ID=transcript:([^;]+);Parent=gene:([^;]+)/ or die "$_\n";
	($trans,$gene)=($1,$2);
            }elsif ($type eq 'NCBI'){
	$a[8]=~/ID=([^;]+);Parent=([^;]+)/ or die "$_\n";
	($trans,$gene)=($1,$2);
            }
            print O "$gene\t$trans\t$len\n";
        }
    }
    close F;
    close O;
}
close IN;
