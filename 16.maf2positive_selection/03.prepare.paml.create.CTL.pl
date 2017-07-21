#!/usr/bin/perl
use strict;
use warnings;

## created by Yongzhi Yang. 2017/3/20 ##

my $type=shift or die "give the model type: branch or branch-site\n";
my @tree=<tree/tree.*>;

for my $tree (@tree){
    $tree=~/tree\/tree\.([^\/]+)$/;
    my $sp=$1;
    if ($sp eq 'raw'){
        open (F,"ctl/ctl.template")||die"$!";
        open (O,">ctl/branch.freeratio.ctl");
        while (<F>) {
            chomp;
            if (/^\s+outfile\s+=/){
	s/outfile\s+=/outfile = branch.freeratio.mlc /;
            }elsif(/^\s+treefile\s+=/){
	s/treefile\s+=/treefile = ..\/..\/tree\/tree.$sp /;
            }elsif(/^\s+model\s+=/){
	s/model\s+=/model = 1 /;
            }elsif(/^\s+NSsites\s+=/){
	s/NSsites\s+=/NSsites = 0 /;
            }elsif(/^\s+fix_omega\s+=/){
	s/fix_omega\s+=/fix_omega = 0 /;
            }elsif(/^\s+omega\s+=/){
	s/omega\s+=/omega = .4 /;
            }
            print O "$_\n";
        }
        close F;
        close O;
        if ($type eq 'branch'){
            open (F,"ctl/ctl.template")||die"$!";
            open (O,">ctl/branch.oneratio.ctl");
            while (<F>) {
	chomp;
	if (/^\s+outfile\s+=/){
	    s/outfile\s+=/outfile = branch.oneratio.mlc /;
	}elsif(/^\s+treefile\s+=/){
	    s/treefile\s+=/treefile = ..\/..\/tree\/tree.$sp /;
	}elsif(/^\s+model\s+=/){
	    s/model\s+=/model = 0 /;
	}elsif(/^\s+NSsites\s+=/){
	    s/NSsites\s+=/NSsites = 0 /;
	}elsif(/^\s+fix_omega\s+=/){
	    s/fix_omega\s+=/fix_omega = 0 /;
	}elsif(/^\s+omega\s+=/){
	    s/omega\s+=/omega = .4 /;
	}
	print O "$_\n";
            }
            close F;
            close O;
        }
    }else{
        if ($type eq 'branch'){
            open (F,"ctl/ctl.template")||die"$!";
            open (O,">ctl/branch.tworatio.$sp.ctl");
            while (<F>) {
	chomp;
	if (/^\s+outfile\s+=/){
	    s/outfile\s+=/outfile = branch.tworatio.$sp.mlc /;
	}elsif(/^\s+treefile\s+=/){
	    s/treefile\s+=/treefile = ..\/..\/tree\/tree.$sp /;
	}elsif(/^\s+model\s+=/){
	    s/model\s+=/model = 2 /;
	}elsif(/^\s+NSsites\s+=/){
	    s/NSsites\s+=/NSsites = 0 /;
	}elsif(/^\s+fix_omega\s+=/){
	    s/fix_omega\s+=/fix_omega = 0 /;
	}elsif(/^\s+omega\s+=/){
	    s/omega\s+=/omega = .4 /;
	}
	print O "$_\n";
            }
            close F;
            close O;
        }elsif($type eq 'branch-site'){
            open (F,"ctl/ctl.template")||die"$!";
            open (O1,">ctl/branch-site.$sp.fix.ctl");
            open (O2,">ctl/branch-site.$sp.nofix.ctl");
            while (<F>) {
	chomp;
	if (/^\s+outfile\s+=/){
	    s/outfile\s+=/outfile = $type.$sp.fix.mlc /;
	    print O1 "$_\n";
	    s/$type.$sp.fix.mlc/$type.$sp.nofix.mlc/;
	    print O2 "$_\n";
	}elsif(/^\s+treefile\s+=/){
	    s/treefile\s+=/treefile = ..\/..\/tree\/tree.$sp /;
	    print O1 "$_\n";
	    print O2 "$_\n";
	}elsif(/^\s+model\s+=/){
	    s/model\s+=/model = 2 /;
	    print O1 "$_\n";
	    print O2 "$_\n";
	}elsif(/^\s+NSsites\s+=/){
	    s/NSsites\s+=/NSsites = 2 /;
	    print O1 "$_\n";
	    print O2 "$_\n";
	}elsif(/^\s+fix_omega\s+=/){
	    s/fix_omega\s+=/fix_omega = 1 /;
	    print O1 "$_\n";
	    s/fix_omega\s+=\s+1/fix_omega = 0 /;
	    print O2 "$_\n";
	}elsif(/^\s+omega\s+=/){
	    s/omega\s+=/omega = 1 /;
	    print O1 "$_\n";
	    s/omega\s+=\s+1/omega = 1.5 /;
	    print O2 "$_\n";
	}else{
	    print O1 "$_\n";
	    print O2 "$_\n";
	}
            }
            close F;
            close O1;
            close O2;
        }else{
            die "branch | branch-site\n";
        }
    }
}
