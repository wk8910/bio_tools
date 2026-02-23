use strict;
use warnings;
use Cwd 'abs_path';

my $Gblocks="/home/share/users/yangyongzhi2012/tools/gblocks/Gblocks_0.91b/Gblocks";

my $dir=shift or die "perl $0 input_dir\nThe \\w+.fa file should contained in the input_dir\n";

my @in=<$dir/*fa>;
for my $in (@in){
    $in=~/\/(\w+)\.fa$/ or die "$in\n";
    my $dir="hyphy_running/$1";
    `mkdir $dir` if (! -e "$dir");
    my $realpath=abs_path($in);
    print "ln -s $realpath $dir/cds.fa ; $Gblocks $dir/cds.fa -t=c \n";
}
