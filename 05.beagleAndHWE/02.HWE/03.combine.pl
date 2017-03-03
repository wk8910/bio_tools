#! /usr/bin/env perl
use strict;
use warnings;
use FileHandle;

my @vcf=@ARGV;
my $out="$0.vcf.gz";

my %fh;
my %black_list;
for(my $i=0;$i<@vcf;$i++){
    my $vcf=$vcf[$i];
    if($vcf=~/vcf$/){
        open $fh{$i},"< $vcf" or die "Cannot open $vcf\n";
    }
    elsif($vcf=~/gz$/){
        open $fh{$i},"zcat $vcf |" or die "Cannot open $vcf\n";
    }
}
my $vcf_num = keys %fh;
sub add_pos{
    my ($chr,$pos)=@_;
    $black_list{$chr}{$pos}++;
    if($black_list{$chr}{$pos} == $vcf_num){
        delete $black_list{$chr}{$pos};
    }
}
foreach my $i(sort keys %fh){
    while(my $l=$fh{$i}->getline()){
	chomp $l;
	next if($l=~/^#/);
	my @a=split(/\s+/,$l);
	&add_pos($a[0],$a[1]);
    }
}
my $black_num=0;
foreach my $chr(keys %black_list){
    foreach my $pos(keys %{$black_list{$chr}}){
	# print "$chr\t$pos\n";
	$black_num++;
    }
}
print STDERR "$black_num sites will be thrown!\n";
foreach my $i(keys %fh){
    close $fh{$i};
}

open O,"| gzip - > $out" or die "Cannot create $out!\n";
if($vcf[0]=~/vcf$/){
    open I,"< $vcf[0]" or die "Cannot open $vcf[0]";
}
elsif($vcf[0]=~/gz$/){
    open I,"zcat $vcf[0] | " or die "Cannot open $vcf[0]";
}
else{
    die "vcf file must be provided with suffix of vcf or vcf.gz!\n";
}

for(my $i=1;$i<@vcf;$i++){
    my $vcf=$vcf[$i];
    if($vcf=~/vcf$/){
        open $fh{$i},"< $vcf" or die "Cannot open $vcf\n";
    }
    elsif($vcf=~/gz$/){
        open $fh{$i},"zcat $vcf |" or die "Cannot open $vcf\n";
    }
}

my $control=0;
my $light=1;
while(my $line=<I>){
    chomp $line;
    if($line!~/^#/){
	my @a=split(/\s+/,$line);
	while(exists $black_list{$a[0]}{$a[1]}){
	    $line=<I>;
	    last if(!$line);
	    chomp $line;
	    @a=split(/\s+/,$line);
	}
	$light=0 if(@a==0);
    }
    my @lines=($line);
    for(my $i=1;$i<@vcf;$i++){
        my $l=$fh{$i}->getline();
	if(!$l){
	    $light = 0;
	    last;
	}
        chomp $l;
	if($l!~/^#/){
	    my @b=split(/\s+/,$l);
	    while(exists $black_list{$b[0]}{$b[1]}){
		$l=$fh{$i}->getline();
		last if(!$l);
		chomp $l;
		@b=split(/\s+/,$l);
	    }
	    $light=0 if(@b==0);
	}
	push @lines,$l;
    }
    last if($light == 0);
    if($line=~/^##/){
        print O "$line\n";
        next;
    }
    my @a=split(/\s+/,$line);
    my @new_line = @a;
    my %alt;
    if($a[4] ne "." && $a[4] ne $a[3]){
        $alt{$a[4]}++;
    }
    my $light=1;
    my $identity=$a[0]."-".$a[1];
    for(my $j=1;$j<@lines;$j++){
        my $l=$lines[$j];
        my @b=split(/\s+/,$l);
	my $test = $b[0]."-".$b[1];
	if($identity ne $test){
	    print STDERR "This could not happen:\n$identity vs $test\n";
	    print join "\n",@lines,"\n";
	    die "\n";
	}
        if($b[4] ne "." && $b[4] ne $a[3]){
            $alt{$b[4]}++;
        }
        for(my $i=9;$i<@b;$i++){
            push @new_line,$b[$i];
        }
    }
    my @alt=keys %alt;
    if(@alt > 1){
        next;
    }
    elsif(@alt==1){
        $new_line[4]=$alt[0];
    }
    else{
        $new_line[4]=$new_line[3];
    }
    if(length($new_line[4])>1 && $a[0]!~/^#/){
	next;
    }
    print O join "\t",@new_line,"\n";
    # last if($control++>10000);
}
close O;

foreach my $i(keys %fh){
    close $fh{$i};
}
