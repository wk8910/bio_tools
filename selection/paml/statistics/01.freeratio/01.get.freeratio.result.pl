use strict;
use warnings;

my $dir=shift or die "perl $0 dir\nthe dir should containing paml result with the following format: dir/clusterid/signal.mlc\n";

open (O,">All.freeratio.result.out");
print O "cluster\tlength\tspeices\tN\tS\tdN\tdS\tNdN\tSdS\tw\tlnl\n";

my @mlc=<$dir/*/branch.freeratio.mlc>;
# my @mlc=<$dir/ENSGACP00000000028/branch.freeratio.mlc>;
for my $mlc (@mlc){
    $mlc=~/\/([^\/]+)\/branch.freeratio.mlc$/;
    my ($cluster)=($1);
    my ($lnl,$N,$S);
    my $len;
    my %flt;
    open (F,"$mlc");
    my $line=0;
    while (<F>){
        chomp;
        if($line==0 && /^\s*$/){
            while(<F>){
	if(/^After deleting gaps/){
	    last;
	}
            }
            next;
        }
        $line++;
        if ($line == 1){
            /^\s+\d+\s+(\d+)$/;
            $len = $1;
            if($len!~/^\d+$/){
	die "The first line should contain length information\n$_\n";
            }
            # print "$_\n";
            # print "$len\n";
        }
        if (/^lnL\(ntime:\s+\d+\s+np:\s+\d+\):\s*(\S+)/){
            $lnl=$1;
        }
        if (/^\s+branch\s+t\s+N\s+S\s+/){
            while (<F>){
	chomp;
	next if /^$/;
	last if /^tree\s+/;
	s/^\s+//;
	my @a=split(/\s+/,$_);
	$N=$a[2];
	$S=$a[3];
            }
        }
        if (/^dS\s+tree:/){
            my $tree=<F>;
            chomp $tree;
            while ($tree=~/(\w+)\:\s*([0-9\.]+)/g){
	my ($id,$ds)=($1,$2);
	$flt{$id}{ds}=$ds;
            }
            #$tree=~/Tsi\:\s+\S+\)\:\s+(\S+),/ or die "$tree\n";
            #$flt{TmiTsi}{ds}=$1;
        }
        if (/^dN\s+tree:/){
            my $tree=<F>;
            chomp $tree;
            while ($tree=~/(\w+)\:\s*([0-9\.]+)/g){
	my ($id,$ds)=($1,$2);
	$flt{$id}{dn}=$ds;
            }
            #$tree=~/Tsi\:\s+\S+\)\:\s+(\S+),/ or die "$tree\n";
            #$flt{TmiTsi}{dn}=$1;
        }
        if (/^w\s+ratios\s+as\s+labels\s+for\s+TreeView/){
            my $tree=<F>;
            chomp $tree;
            while ($tree=~/(\w+)\s+\#([0-9\.]+)/g){
	my ($id,$ds)=($1,$2);
	$flt{$id}{w}=$ds;
            }
            #((((Tmi #0.129517 , Tsi #0.147104 ) #0.0678384 , (Cid #0.174565 , Dre #0.0588215 ) #0.0272514 ) #0.0880625 , (Ame #0.16252 , Ipu #0.0802428 ) #0.00530608 ) #0.0001 , Ola #0.0490154 );
            #$tree=~/Tsi\s+\S+\s*\)\s+\#(\S+)\s*,/ or die "$tree\n";
	    #$flt{TmiTsi}{w}=$1;
        }
    }
    close F;
    for my $k (sort keys %flt){
        print O "$cluster\t$len\t$k\t$N\t$S\t$flt{$k}{dn}\t$flt{$k}{ds}\t",$N*$flt{$k}{dn},"\t",$S*$flt{$k}{ds},"\t$flt{$k}{w}\t$lnl\n";
    }
}
close O;
