#！/usr/bin/perl
use strict;
use warnings;
my $in = shift;
my $out = "$in.regular.tre";

open I ,"< $in" or die "perl tree.pl <filename> !\n";

my $str = <I>;
#    my @sp = $str =~ /([a-z]+[0-9]?)/ig;

close I ;

my $copy = $str ;
$copy =~ s/\(/ \( /g;
$copy =~ s/\)/ \) /g;
$copy =~ s/\:/ \: /g;
$copy =~ s/\,/ \, /g;

my @sp;
my $clear=$str;
$clear=~s/:[\d\.e\-]+//g;
$clear=~s/[\(\)\;\,\:]/ /g;
my @all = split (/\s+/,$clear);
foreach my $all (@all){
    if ($all =~ /[a-z]+/i){
        push @sp ,$all;
    }
}

#print @sp;

my %tree ;
my $max = 0 ;
my %branch;
foreach my $name (@sp){
    # print "$name\t";
    my @a = split(/ $name /,$copy);
    my @element = split (/\s+/,$a[1]);
    # print "@element\n";
    $tree{$name} = 0 ;
    my ( $left , $right , $num , $total , $sum ) = ( 0,0,0,0,0 );
    foreach my $e (@element){
        $left-- if ($e =~ /\(/) ;
        if ($e =~ /\)/) {
            $right++;
            $total = $left + $right + $num ;
        }
        if($e =~/[\de\-\.]+/){
            #next if ($e =~ /[a-z]/i);
            if ($total == 0){
	#print "$name\t$e\n";
	$sum = $sum + $e ;
	if ( $num == 0 ) {
	    $branch{$name}=$e;
	}
	#print $num;
	$total++;
	$num--;
	$max=$sum if ($max < $sum) ;
	$tree{$name}=$sum;
            }
        }
    }
    # print "$sum\n";
}

# print "$max";
foreach my $name (@sp){
    my $b ;
    my $a = $tree{$name} ;
    my $c = $branch{$name};
    $b=$max-$a+$c ;
    $str =~ s/([(,]$name):[\de\-\.]+/$1:$b/;
}

open O ,"> $out ";
print O "$str";
close O ;
