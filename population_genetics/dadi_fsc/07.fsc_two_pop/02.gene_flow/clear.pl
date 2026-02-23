#! /usr/bin/env perl
use strict;
use warnings;

if(-e "replicates"){
    `rm -r replicates`;
}
if(-e "model"){
    `rm -r model`;
}
if(-e "seed.txt"){
    `rm seed.txt`;
}
if(-e "model.par"){
    `rm model.par`;
}
if(-e "MRCAs.txt"){
    `rm MRCAs.txt`;
}
`touch clear.pl~`;
`rm *~`;
