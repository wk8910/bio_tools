#! /usr/bin/perl
# This script is used to split a command file in to several small command file.
use strict;
use warnings;
use List::Util;
use FileHandle;

my ($task, $num, $disorder)=@ARGV;
die("Usage: $0 <tasklist> <num> [disorder Y/N]\n") if(!$task || !$num || !-e "$task" || $num!~/^\d+$/);

open(IN,"< $task")||die("Cannot open $task!\n");
my @cmd = <IN>;
my $all_num = @cmd;
if($disorder){
    @cmd = List::Util::shuffle @cmd;
}
my %fh;
for(my $i = 1; $i <= $num; $i++){
    open($fh{$i}, "> $task.run$i.shi");
}

my $i=0;
foreach my $cmd(@cmd){
    $i++;
    if($i>$num){
        $i=$i-$num;
    }
    $fh{$i}->print("$cmd");
}
close IN;
foreach my $i(keys %fh){
    close $fh{$i};
}
