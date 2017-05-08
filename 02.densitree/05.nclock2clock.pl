#! /usr/bin/env perl
use strict;
use warnings;
use Math::BigFloat;

my $rrtre="04.reroot.pl.rrtre";

open R,"> $0.Rscript";
print R "library('phybase');\n";
open I,"< $rrtre";
while(<I>){
    chomp;
    my $tre=$_;
    my $new_tre=$tre;
    while($tre=~/(\d+.\d+E-\d)/){
        my $x=$1;
        my $y = new Math::BigFloat $x;
        $new_tre=~s/$x/$y/;
        $tre=$new_tre;
    }
    print R "treestr<-\"$new_tre\";
name<-species.name(treestr);
name_len<-length(name);
treenode<-read.tree.nodes(treestr,name)\$nodes;
node_len<-nrow(treenode);
newnode=noclock2clock(node_len,treenode,name_len);
tree<-write.subtree(node_len,newnode,name,node_len);
cat(tree)
cat(\"\n\")
";
}
close I;
close R;
print "Rscript $0.Rscript > $0.clocktre\n";
