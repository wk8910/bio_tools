use strict;
use warnings;

my $dir=shift or die "perl $0 dir\nthe dir should containing paml result with the following format: dir/clusterid/signal.mlc\n";

open (O,">All.branchsite.result.out");
print O "cluster\tlength\tspeices\ttype\tlnl\tw\tBEB\n";

my @mlc=<$dir/*/branch-site.*mlc>; 
for my $mlc (@mlc){
    $mlc=~/\/([^\/]+)\/branch-site\.(\w+)\.(nofix|fix)\.mlc$/;
    my ($cluster,$species,$type)=($1,$2,$3);
    my ($w,$lnl,@beb);
    my $len;
    open (F,"$mlc");
    my $line=0;
    while (<F>){
        chomp;
        $line++;
        if ($line == 1){
            /^\s+\d+\s+(\d+)$/;
            $len = $1;
        }
        if (/^lnL\(ntime:\s+\d+\s+np:\s+\d+\):\s*(\S+)/){
            $lnl=$1;
        }
        if (/^foreground\s+w/){
            if (/^foreground\s+w\s+\S+\s+\S+\s+(\S+)\s+(\S+)$/){
	my @w=sort{$a<=>$b} ($1,$2);
	$w=$w[1];
            }else{
	print "$_\n";
            }
        }
        if (/^Bayes\s+Empirical\s+Bayes\s+\(BEB\)/){
            while (<F>){
	chomp;
	if (/^\s+(\d+)\s+(\w+)\s+(\S+)/){
	    my $beb="$1:$2:$3";
	    push @beb,$beb;
	}
	last if /^\s*$/;
            }
        }
    }
    close F;
    if (! $lnl){
        print "$mlc\n";
        next;
    }
    if (scalar(@beb) > 0){
        print O "$cluster\t$len\t$species\t$type\t$lnl\t$w\t",join(";",@beb),"\n";
    }else{
        print O "$cluster\t$len\t$species\t$type\t$lnl\t$w\tNA\n";
    }
}
close O;
