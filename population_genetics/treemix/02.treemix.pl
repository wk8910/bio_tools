#! /usr/bin/env perl
use strict;
use warnings;

my $file="noBuffalo.gz";
my $output_dir="twentyOne";
my $root="cattle";
`mkdir $output_dir` if(!-e "$output_dir");

open(O1,"> run_treemix.sh");
open(O2,"> run_plot.Rscript");
for(my $i=0;$i<5;$i++){
    my $m_para="";
    if($i>0){
        $m_para=" -m $i";
    }
    print O1 "~/software/treemix/treemix-1.12-build/bin/treemix -i $file$m_para -root $root -o $output_dir/out_$i > $output_dir/out_$i.log\n";
    print O2 "source('~/software/treemix/treemix-1.12/src/plotting_funcs.R')\n";
    print O2 "pdf(file='$output_dir/out_$i.pdf')
plot_tree('$output_dir/out_$i')
plot_resid('$output_dir/out_$i','order.txt')
dev.off()
";
}
close O1;
close O2;
