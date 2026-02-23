#! /usr/bin/env perl
use strict;
use warnings;

my ($fasta_file)=@ARGV;
my $cpu=1;
my $ml_num=20;
die "Usage: $0 <fasta file>\n" if(@ARGV<1);

my $clustalw="/home/share/user/user101/software/clustalw/clustalw-2.1-linux-x86_64-libcppstatic/clustalw2";
my $raxml="/home/share/user/user101/software/raxml/standard-RAxML/raxmlHPC-PTHREADS-AVX";
my $parser="/home/share/user/user101/software/examl/ExaML/parser/parse-examl";
my $examl="/home/share/user/user101/software/examl/ExaML/examl/examl-AVX";
my $now=$ENV{'PWD'};

$fasta_file=~/([^\/]+)$/;
my $fasta_id=$1;
if ($fasta_id=~/(.*)\.[^\.]+$/){
    $fasta_id=$1;
}

### convert fasta to phylip

my $inter_phy = "align.phy";
my $command = "$clustalw -INFILE=$fasta_file -CONVERT -OUTFILE=$inter_phy -OUTPUT=PHYLIP";
`$command`;

### generate bootstrap sequence

my $boot_dir = "bootseq";
`mkdir $boot_dir` if(!-e $boot_dir);
$command = "cd $now/$boot_dir; ln -s $now/$inter_phy . ; $raxml -N 100 -b 271828 -f j -m GTRGAMMA -s $inter_phy -n REPS; cd -";
`$command`;

### generate guide tree

my @BS=<$boot_dir/*.BS*>;
open O,"> $0.step01.guideTree.sh";
for(my $i=0;$i<$ml_num;$i++){
    my $seed=10000+int(rand(1)*10000);
    print O "$raxml -y -s $inter_phy -n $inter_phy.$i -m GTRCAT -p $seed\n";
}
foreach my $BS(@BS){
    $BS=~/([^\/]+)$/;
    my $bs_id=$1;
    print O "cd $now/$boot_dir; $raxml -y -s $bs_id -n $bs_id -m GTRCAT -p 31415; cd -\n";
}
close O;

### convert to bin

my $inter_bin="align.bin";
open O,"> $0.step02.convert.sh";
print O "$parser -s $inter_phy -n $inter_bin -m DNA\n";
foreach my $BS(@BS){
    $BS=~/([^\/]+)$/;
    my $bs_id=$1;
    print O "cd $now/$boot_dir; $parser -s $bs_id -n $bs_id.bin -m DNA; cd -\n";
}
close O;

### build tree

my $main_tree_name="main.tre";
open O,"> $0.step03.examl.sh";
for(my $i=0;$i<$ml_num;$i++){
    print O "mpirun -n $cpu $examl -s $inter_bin.binary -n $main_tree_name.$i -t RAxML_parsimonyTree.$inter_phy.$i -m GAMMA\n";
}
foreach my $BS(@BS){
    $BS=~/([^\/]+)$/;
    my $bs_id=$1;
    print O "cd $boot_dir; mpirun -n $cpu $examl -s $bs_id.bin.binary -n $bs_id.examl -t RAxML_parsimonyTree.$bs_id -m GAMMA; cd -\n";
}
close O;

### combine tree

my $boot_trees="TREES";
my $final_tre="bootstrap.tre";
open O,"> $0.step04.bootstrap.sh";
print O "perl get_best_tree.pl $main_tree_name\n";
print O "cat $now/$boot_dir/*result* > $boot_trees\n";
print O "$raxml -f b -m GTRGAMMA -s $inter_bin.binary -z $boot_trees -t ExaML_result.$main_tree_name -n $final_tre\n";
close O;
