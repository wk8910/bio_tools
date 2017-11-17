use strict;
use warnings;

my ($in,$timescale,$ci)=@ARGV;
die "perl $0 inputNEXUS.tree timescale retain_CI[yes|no]\n" if (! $ci);

$ci=lc($ci);

my $tree0="NA";
open (F,"$in");
while (<F>) {
    chomp;
    if (/^\s+(Utree|tree)\s+\d+\s+=\s+(.*)$/i){
        $tree0=$2;
    }
}
close F;
die "check tree file\n" if $tree0 eq 'NA';
my %replace;
while ($tree0=~/:\s*([0-9\.]+)/g) {
    my $rawnum=$1;
    my $newnum=$rawnum * $timescale;
    #$tree0=~s/\Q$rawnum\E/$newnum/;
    $replace{$rawnum}=$newnum;
}
while ($tree0=~/{([0-9\.]+),\s*([0-9\.]+)}/g){
    my $rawnum1=$1;
    my $newnum1=$rawnum1 * $timescale;
    my $rawnum2=$2;
    my $newnum2=$rawnum2 * $timescale;
    #$tree0=~s/\Q$rawnum1\E/$newnum1/;
    #$tree0=~s/\Q$rawnum2\E/$newnum2/;
    #$tree0=~s/\:\s*([0-9\.]+)/: $1*$timescale/ig;
    #$tree0=~s/\[\&95%=\{([0-9\.]+),([0-9\.]+)\}\]/\[\&95%=\{$1*$timescale,$2*$timescale\}\]/ig;
    $replace{$rawnum1}=$newnum1;
    $replace{$rawnum2}=$newnum2;
}
for my $k (sort keys %replace){
    my $v=$replace{$k};
    $tree0=~s/\Q$k\E/$v/g;
}

if ($ci eq 'yes'){
    print "$tree0\n";
}elsif ($ci eq 'no'){
    $tree0=~s/\s+\[\&95%=\{([0-9\.]+),\s*([0-9\.]+)\}\]//g;
    print "$tree0\n";
}
