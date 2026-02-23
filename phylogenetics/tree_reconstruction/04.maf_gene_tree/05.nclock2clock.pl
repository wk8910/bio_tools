#! /usr/bin/env perl
use strict;
use warnings;
use Math::BigFloat;

my $rrtre="04.collect_high_confidence.pl.phb";

open R,"> $0.Rscript";
print R "library('phybase');\n";
open I,"< $rrtre";
while(<I>){
    chomp;
    next if(/:0\.0,/);
    my $tre=$_;
    my $new_tre=$tre;
    while($tre=~/(\d+.\d+E-\d)/){
        my $x=$1;
        my $y = new Math::BigFloat $x;
        $new_tre=~s/$x/$y/;
        $tre=$new_tre;
    }
    # newnode=noclock2clock(node_len,treenode,name_len); this line is to make all tree have a same root length
    print R "treestr<-\"$new_tre\";
name<-species.name(treestr);
name_len<-length(name);
treenode<-read.tree.nodes(treestr,name)\$nodes;
node_len<-nrow(treenode);
newnode=noclock2clock(node_len,treenode,name_len);
node_height=node.height(node_len,newnode,name_len);
newnode[,4]=newnode[,4]*(1/node_height);
tree<-write.subtree(node_len,newnode,name,node_len);
cat(tree)
cat(\"\n\")
";
}
close I;
close R;
print "Rscript $0.Rscript > $0.clocktre\n";
