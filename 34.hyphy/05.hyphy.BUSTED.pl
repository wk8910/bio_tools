use strict;
use warnings;
use Cwd 'abs_path';

my $inputdir=shift or die "perl $0 inputdir treefile\nThe */\\w+.fa-gb.flt file should contained in the inputdir\n";
my $tree=shift or die "perl $0 inputdir treefile\nThe */\\w+.fa-gb.flt file should contained in the inputdir\n";
my $realpath_tree=abs_path($tree);

my $hyphy="/home/share/users/yangyongzhi2012/tools/hyphy/hyphy-2.3.6-build/bin/HYPHYMPI";
die "no hyphy found in $hyphy\n" if (! -e "$hyphy");

my @in=<$inputdir/*/*fa-gb.flt>;
my $pwd=`pwd`;
chomp $pwd;
open (SH,">$0.sh");
for my $in (@in){
    $in=~/^(\S+)\/(\w+)\.fa-gb.flt/ or die "$in\n";
    my $dir="$1";
    my $realpath_fa=abs_path($in);
    open (O,">$dir/hyphy_BUSTED_config.txt");
    print O "1\n5\n1\n$realpath_fa\n$realpath_tree\n1\n";
    close O;
    print SH "cd $dir ; $hyphy < hyphy_BUSTED_config.txt ; cd $pwd\n";
}
close SH;
