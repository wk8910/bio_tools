#! /usr/bin/perl
###############################################################################
# InParanoid version 4.1
# Copyright (C) Erik Sonnhammer, Kristoffer Forslund, Isabella Pekkari, 
# Ann-Charlotte Berglund, Maido Remm, 2007
#
# This program is provided under the terms of a personal license to the recipient and may only 
# be used for the recipient's own research at an academic insititution.
#
# Distribution of the results of this program must be discussed with the authors.
# For using this program in a company or for commercial purposes, a commercial license is required. 
# Contact Erik.Sonnhammer@sbc.su.se in both cases
#
# Make sure that Perl XML libraries are installed!
#
# NOTE: This script requires blastall (NCBI BLAST) version 2.2.16 or higher, that supports 
# compositional score matrix adjustment (-C2 flag).

my $usage =" Usage: inparanoid.pl <FASTAFILE with sequences of species A> <FASTAFILE with sequences of species B> [FASTAFILE with sequences of species C]

";

###############################################################################
# The program calculates orthologs between 2 datasets of proteins 
# called A and B. Both datasets should be in multi-fasta file
# - Additionally, it tries to assign paralogous sequences (in-paralogs) to each 
#   thus forming paralogous clusters. 
# - Confidence of in-paralogs is calculated in relative scale between 0-100%.
#   This confidence value is dependent on how far is given sequence from the
#   seed ortholog of given group
# - Confidence of groups can be calculated with bootstrapping. This is related 
#   to score difference between best hit and second best hit.
# - Optionally it can use a species C as outgroup.

###############################################################################
# You may need to run the following command manually to increase your 
# default datasize limit: 'limit datasize 500000 kb'

###############################################################################
# Set following variables:                                                    #
###############################################################################

# What do you want the program to do?                                         #
$run_blast = 1;  # Set to 1 if you don't have the 4 BLAST output files        #
                 # Requires 'blastall', 'formatdb' (NCBI BLAST2)              #
                 # and parser 'blast_parser.pl'                               #
$blast_two_passes = 0;  # Set to 1 to run 2-pass strategy                     #
                 # (strongly recommended, but slower)                         #
$run_inparanoid = 1;
$use_bootstrap = 1;# Use bootstrapping to estimate the confidence of orthologs#
                   # Needs additional programs 'seqstat.jar' and 'blast2faa.pl'
$use_outgroup = 0; # Use proteins from the third genome as an outgroup        #
                   # Reject best-best hit if outgroup sequence is MORE        #
                   # similar to one of the sequences                          #
                   # (by more than $outgroup_cutoff bits)                     #

# Define location of files and programs:
#$blastall = "blastall -VT"; #Remove -VT for blast version 2.2.12 or earlier
$blastall = "/home/share/software/blast/blastall-2.2.26/blast-2.2.26/bin/blastall -a32";  #Add -aN to use N processors
$formatdb = "/home/share/software/blast/blastall-2.2.26/blast-2.2.26/bin/formatdb";
my $ncpu=20; # cpu number for ghostz
$ghostz = "~/software/ghostz/ghostz-1.0.0/ghostz";
$seqstat = "seqstat.jar";
$blastParser = "blast_parser.pl";
$ghostParser = "ghostz_parser.pl";

$matrix = "BLOSUM62"; # Reasonable default for comparison of eukaryotes.
#$matrix = "BLOSUM45"; #(for prokaryotes),
#$matrix = "BLOSUM80"; #(orthologs within metazoa),
#$matrix = "PAM70";
#$matrix = "PAM30";

# Output options:                                                              #
$output = 1;      # table_stats-format output                                  #
$table = 1;       # Print tab-delimited table of orthologs to file "table.txt" #
                  # Each orthologous group with all inparalogs is on one line  #
$mysql_table = 1; # Print out sql tables for the web server                    #
                  # Each inparalog is on separate line                         #
$html = 1;        # HTML-format output                                         #

# Algorithm parameters:                                                        
# Default values should work without problems.
# MAKE SURE, however, that the score cutoff here matches what you used for BLAST!
$score_cutoff = 40;    # In bits. Any match below this is ignored             #
$outgroup_cutoff = 50; # In bits. Outgroup sequence hit must be this many bits#
                       # stronger to reject best-best hit between A and B     #
$conf_cutoff = 0.05;   # Include in-paralogs with this confidence or better   #
$group_overlap_cutoff = 0.5; # Merge groups if ortholog in one group has more #
                             # than this confidence in other group            #
$grey_zone = 0;  # This many bits signifies the difference between 2 scores   #
$show_times = 0; # Show times spent for execution of each part of the program #
                 # (This does not work properly)                              #
$debug = 0;      # Print debugging messages or not. Levels 0,1,2 and 4 exist  #

my $seq_overlap_cutoff = 0.5; 		# Match area should cover at least this much of longer sequence. Match area is defined as area from start of
					# first segment to end of last segment, i.e segments 1-10 and 90-100 gives a match length of 100.
my $segment_coverage_cutoff = 0.25; 	# Actually matching segments must cover this much of longer sequence. 
					# For example, segments 1-10 and 90-100 gives a total length of 20.

###############################################################################
# No changes should be required below this line                               #
###############################################################################
$ENV{CLASSPATH} = "./$seqstat" if ($use_bootstrap);

if (!@ARGV){
    print STDERR $usage;
    exit 1;
}

if ((@ARGV < 2) and ($run_inparanoid)){
    print STDERR "\n When \$run_inparanoid=1, at least two distinct FASTA files have to be specified.\n";

    print STDERR $usage;
    exit 1;
}

if ((!$run_blast) and (!$run_inparanoid)){
    print STDERR "run_blast or run_inparanoid has to be set!\n";
    exit 1;
}

# Input files:                                                            
$fasta_seq_fileA = "$ARGV[0]";                                            
$fasta_seq_fileB = "$ARGV[1]";                                            
$fasta_seq_fileC = "$ARGV[2]" if ($use_outgroup); # This is outgroup file  

my $blast_outputAB = $fasta_seq_fileA . "-" . $fasta_seq_fileB;
my $blast_outputBA = $fasta_seq_fileB . "-" . $fasta_seq_fileA;
my $blast_outputAA = $fasta_seq_fileA . "-" . $fasta_seq_fileA;
my $blast_outputBB = $fasta_seq_fileB . "-" . $fasta_seq_fileB;

if ($use_outgroup){
    $blast_outputAC = $fasta_seq_fileA . "-" . $fasta_seq_fileC;
    $blast_outputBC = $fasta_seq_fileB . "-" . $fasta_seq_fileC;
}
my %idA;        # Name -> ID combinations for species 1
my %idB;        # Name -> ID combinations for species 2
my @nameA;      # ID -> Name combinations for species 1
my @nameB;      # ID -> Name combinations for species 2
my @nameC;
my %scoreAB;    # Hashes with pairwise BLAST scores (in bits)
my %scoreBA;
my %scoreAA;
my %scoreBB;
my @hitnAB;     # 1-D arrays that keep the number of pairwise hits
my @hitnBA;
my @hitnAA;
my @hitnBB;
my @hitAB;      # 2-D arrays that keep the actual matching IDs 
my @hitBA;
my @hitAA;
my @hitBB;
my @besthitAB;  # IDs of best hits in other species (may contain more than one ID)
my @besthitBA;  # IDs of best hits in other species (may contain more than one ID)
my @bestscoreAB; # best match A -> B 
my @bestscoreBA; # best match B -> A 
my @ortoA;      # IDs of ortholog candidates from species A 
my @ortoB;      # IDs of ortholog candidates from species B
my @ortoS;      # Scores between ortoA and ortoB pairs
my @paralogsA;  # List of paralog IDs in given cluster
my @paralogsB;  # List of paralog IDs in given cluster
my @confPA;     # Confidence values for A paralogs
my @confPB;     # Confidence values for B paralogs
my @confA;      # Confidence values for orthologous groups
my @confB;      # Confidence values for orthologous groups 
my $prev_time = 0;

$outputfile = "Output." . $ARGV[0] . "-" . $ARGV[1];
if ($output){
    open OUTPUT, ">$outputfile" or warn "Could not write to OUTPUT file $filename\n";
}

#################################################
# Assign ID numbers for species A
#################################################
open A, "$fasta_seq_fileA" or die "File A with sequences in FASTA format is missing
Usage $0 <FASTAFILE with sequences of species A> <FASTAFILE with sequences of species B> <FASTAFILE with sequences of species C>\n";
$id = 0;
while (<A>){
    if(/^\>/){
	++$id;
	chomp;
	s/\>//;
	@tmp = split(/\s+/);
	#$name = substr($tmp[0],0,25);
	$name = $tmp[0];
	$idA{$name} = int($id);
	$nameA[$id] = $name;
    }
}
close A;
$A = $id;
print "$A sequences in file $fasta_seq_fileA\n";

if ($output){
    print OUTPUT "$A sequences in file $fasta_seq_fileA\n";
}

if (@ARGV >= 2) {
#################################################
# Assign ID numbers for species B
#################################################
    open B, "$fasta_seq_fileB" or die "File B with sequences in FASTA format is missing
Usage $0 <FASTAFILE with sequences of species A> <FASTAFILE with sequences of species B> <FASTAFILE with sequences of species C>\n";
    $id = 0;
    while (<B>){
	if(/^\>/){
	    ++$id;
	    chomp;
	    s/\>//;
	    @tmp = split(/\s+/);
	    #$name = substr($tmp[0],0,25);
	    $name = $tmp[0];
	    $idB{$name} = int($id);
	    $nameB[$id] = $name;
	}
    }
    $B = $id;
    print "$B sequences in file $fasta_seq_fileB\n";
    close B;

    if ($output){
	print OUTPUT "$B sequences in file $fasta_seq_fileB\n";
    }
}
#################################################
# Assign ID numbers for species C (outgroup)
#################################################
if ($use_outgroup){
    open C, "$fasta_seq_fileC" or die "File C with sequences in FASTA format is missing
   Usage $0 <FASTAFILE with sequences of species A> <FASTAFILE with sequences of species B> <FASTAFILE with sequences of species C>\n";
    $id = 0;
    while (<C>){
	if(/^\>/){
	    ++$id;
	    chomp;
	    s/\>//;
	    @tmp = split(/\s+/);
	    #$name = substr($tmp[0],0,25);
	    $name = $tmp[0];
	    $idC{$name} = int($id);
	    $nameC[$id] = $name;
	}
    }
    $C = $id;
    print "$C sequences in file $fasta_seq_fileC\n";
    close C;
    if ($output){
	print OUTPUT "$C sequences in file $fasta_seq_fileC\n";
    }
}
if ($show_times){
    ($user_time,,,) = times;
    printf ("Indexing sequences took %.2f seconds\n", ($user_time - $prev_time));
    $prev_time = $user_time;
}

#################################################
# Run BLAST if not done already
#################################################
if ($run_blast){
    print "Trying to run GHOSTZ now - this may take several hours ... or days in worst case!\n";
    print STDERR "Formatting GHOSTZ databases\n";
    system ("$ghostz db -i $fasta_seq_fileA -o $fasta_seq_fileA");
    system ("$ghostz db -i $fasta_seq_fileB -o $fasta_seq_fileB") if (@ARGV >= 2);
    system ("$ghostz db -i $fasta_seq_fileZ -o $fasta_seq_fileZ") if ($use_outgroup);   
    print STDERR "Done formatting\nStarting GHOSTZ searches...\n";

# Run blast only if the files do not already exist is not default. 
# NOTE: you should have done this beforehand, because you probably
# want two-pass blasting anyway which is not implemented here
# this is also not adapted to use specific compositional adjustment settings
# and might not use the proper blast parser...

    do_blast ($fasta_seq_fileA, $fasta_seq_fileA, $A, $A, $blast_outputAA);

    if (@ARGV >= 2) {
      do_blast ($fasta_seq_fileA, $fasta_seq_fileB, $B, $B, $blast_outputAB);
      do_blast ($fasta_seq_fileB, $fasta_seq_fileA, $A, $A, $blast_outputBA);
      do_blast ($fasta_seq_fileB, $fasta_seq_fileB, $B, $B, $blast_outputBB);
    }

    if ($use_outgroup){

	do_blast ($fasta_seq_fileA, $fasta_seq_fileC, $A, $C, $blast_outputAC);
	do_blast ($fasta_seq_fileB, $fasta_seq_fileC, $B, $C, $blast_outputBC);
    }

    if ($show_times){
	($user_time,,,) = times;
	printf ("GHOSTZ searches took %.2f seconds\n", ($user_time - $prev_time));
	$prev_time = $user_time;
    }
    print STDERR "Done GHOSTZ searches. ";

} else {
	print STDERR "Skipping blast! \n";
}

if ($run_inparanoid){
    print STDERR "Starting ortholog detection...\n";   
#################################################
# Read in best hits from blast output file AB
#################################################
    $count = 0;
    open AB, "$blast_outputAB" or die "Blast output file A->B is missing\n";
    $old_idQ = 0;
    while (<AB>){
        chomp;
        # print STDERR "haaaloooo!\n";
	@Fld = split(/\s+/);    # Get query, match and score

	if( scalar @Fld < 9 ){
	    if($Fld[0]=~/done/){
	        print STDERR "AB ok\n";
	    }
	    next;
	} 

	$q = $Fld[0];
	$m = $Fld[1];
	$idQ = $idA{$q}; # ID of query sequence
	$idM = $idB{$m}; # ID of match sequence
	$score = $Fld[2];

	next if (!overlap_test(@Fld));

	# Score must be equal to or above cut-off
	next if ($score < $score_cutoff);

	if(!$count || $q ne $oldq){
	    print "Match $m, score $score, ID for $q is missing\n" if ($debug == 2 and !(exists($idA{$q})));
	    $hitnAB[$idA{$oldq}] = $hit if($count); # Record number of hits for previous query
	    $hit = 0;
	    ++$count;
	    $oldq = $q;
	}
	++$hit;
	$hitAB[$idQ][$hit] = int($idM);
#	printf ("hitAB[%d][%d] = %d\n",$idQ,$hit,$idM);
	$scoreAB{"$idQ:$idM"} = $score;
	$scoreBA{"$idM:$idQ"} = $score_cutoff; # Initialize mutual hit score - sometimes this is below score_cutoff
	$old_idQ = $idQ;
#    }
    }
    $hitnAB[$idQ] = $hit; # For the last query
#printf ("hitnAB[1] = %d\n",$hitnAB[1]); 
#printf ("hitnAB[%d] = %d\n",$idQ,$hit); 
    close AB;
    if ($output){
	print OUTPUT "$count sequences $fasta_seq_fileA have homologs in dataset $fasta_seq_fileB\n";
    }
#################################################
# Read in best hits from blast output file BA
#################################################
    $count = 0;
    open BA, "$blast_outputBA" or die "Blast output file B->A is missing\n";
    $old_idQ = 0;
    while (<BA>){
	chomp;
	@Fld = split(/\s+/);    # Get query, match and score

	if( scalar @Fld < 9 ){
	    if($Fld[0]=~/done/){
		print STDERR "BA ok\n";
	    }
	    next;
	} 

	$q = $Fld[0];
	$m = $Fld[1];
	$idQ = $idB{$q};
	$idM = $idA{$m};	 
	$score = $Fld[2];
	
	next if (!overlap_test(@Fld));
	
	next if ($score < $score_cutoff);
	
	if(!$count || $q ne $oldq){
	    print "ID for $q is missing\n" if ($debug == 2 and (!exists($idB{$q})));
	    $hitnBA[$idB{$oldq}] = $hit if($count); # Record number of hits for previous query
	    $hit = 0;
	    ++$count;
	    $oldq = $q;
	}
	++$hit;
	$hitBA[$idQ][$hit] = int($idM);
#	printf ("hitBA[%d][%d] = %d\n",$idQ,$hit,$idM);
	$scoreBA{"$idQ:$idM"} = $score;   
	$scoreAB{"$idM:$idQ"} = $score_cutoff if ($scoreAB{"$idM:$idQ"} < $score_cutoff); # Initialize missing scores
	$old_idQ = $idQ;
#    }
    }
    $hitnBA[$idQ] = $hit; # For the last query
#printf ("hitnBA[%d] = %d\n",$idQ,$hit); 
    close BA;
    if ($output){
	print OUTPUT "$count sequences $fasta_seq_fileB have homologs in dataset $fasta_seq_fileA\n";
    }
##################### Equalize AB scores and BA scores ##########################

###################################################################################################################################### Modification by Isabella 1

	# I removed the time consuming all vs all search and equalize scores for all pairs where there was a hit

    	foreach my $key (keys %scoreAB) {

		my ($a, $b) = split(':', $key);
		my $key2 = $b . ':' . $a;

		# If debugg mod is 5 and the scores A-B and B-A are unequal
	   	 # the names of the two sequences and their scores are printed
	    	if ($scoreAB{$key} != $scoreBA{$key2}){
			printf ("%-20s\t%-20s\t%d\t%d\n",$nameA[$a], $nameB[$b], $scoreAB{$key}, $scoreBA{$key2}) if ($debug == 5);
	    	}

		# Set score AB and score BA to the mean of scores AB and BA.
	  	# The final score is saved as an integer so .5 needs to be added to avoid rounding errors
	    	$scoreAB{$key} = $scoreBA{$key2} = int(($scoreAB{$key} + $scoreBA{$key2})/2.0 +.5);
	}

    # For all ids for sequences from organism A	
    #for $a(1..$A){
	#For all ids for sequences from organism B
	#for $b(1..$B){

	    # No need to equalize score if there was no match between sequence with id $a from species A
	    # and sequence with id $b from species B
	 #   next if (!$scoreAB{"$a:$b"});

	    # If debugg mod is 5 and the scores A-B and B-A are unequal
	    # the names of the two sequences and their scores are printed
	  #  if ($scoreAB{"$a:$b"} != $scoreBA{"$b:$a"}){
	#	printf ("%-20s\t%-20s\t%d\t%d\n",$nameA[$a], $nameB[$b], $scoreAB{"$a:$b"}, $scoreBA{"$b:$a"}) if ($debug == 5);
	 #   }

	    # Set score AB and score BA to the mean of scores AB and BA.
	    # The final score is saved as an integer so .5 needs to be added to avoid rounding errors
	 #   $scoreAB{"$a:$b"} = $scoreBA{"$b:$a"} = int(($scoreAB{"$a:$b"} + $scoreBA{"$b:$a"})/2.0 +.5);

#	printf ("scoreAB{%d: %d} = %d\n",	$a, $b, $scoreAB{"$a:$b"});
#	printf ("scoreBA{%d: %d} = %d\n",	$b, $a, $scoreBA{"$a:$b"});
	#}
#    }

####################################################################################################################################### End modification by Isabella 1

##################### Re-sort hits, besthits and bestscore #######################
    for $idA(1..$A){
#    print "Loop index = $idA\n";
#    printf ("hitnAB[%d] = %d\n",$idA, $hitnAB[$idA]);
	next if (!($hitnAB[$idA]));
	for $hit (1..($hitnAB[$idA]-1)){ # Sort hits by score
	    while($scoreAB{"$idA:$hitAB[$idA][$hit]"} < $scoreAB{"$idA:$hitAB[$idA][$hit+1]"}){ 
		$tmp = $hitAB[$idA][$hit];
		$hitAB[$idA][$hit] = $hitAB[$idA][$hit+1];
		$hitAB[$idA][$hit+1] = $tmp;
		--$hit if ($hit > 1);      
	    }
	}
	$bestscore = $bestscoreAB[$idA] = $scoreAB{"$idA:$hitAB[$idA][1]"};
	$besthitAB[$idA] = $hitAB[$idA][1];   
	for $hit (2..$hitnAB[$idA]){
	    if ($bestscore - $scoreAB{"$idA:$hitAB[$idA][$hit]"} <= $grey_zone){
		$besthitAB[$idA] .= " $hitAB[$idA][$hit]";
	    }
	    else {
		last;
	    }
	}
	undef $is_besthitAB[$idA]; # Create index that we can check later
	grep (vec($is_besthitAB[$idA],$_,1) = 1, split(/ /,$besthitAB[$idA]));
#    printf ("besthitAB[%d] = hitAB[%d][%d] = %d\n",$idA,$idA,$hit,$besthitAB[$idA]);
	
    }
    
    for $idB(1..$B){
#    print "Loop index = $idB\n";
	next if (!($hitnBA[$idB]));
	for $hit (1..($hitnBA[$idB]-1)){
# Sort hits by score
	    while($scoreBA{"$idB:$hitBA[$idB][$hit]"} < $scoreBA{"$idB:$hitBA[$idB][$hit+1]"}){
		$tmp = $hitBA[$idB][$hit];
		$hitBA[$idB][$hit] = $hitBA[$idB][$hit+1];
		$hitBA[$idB][$hit+1] = $tmp;
		--$hit if ($hit > 1);
	    }
	}
	$bestscore = $bestscoreBA[$idB] = $scoreBA{"$idB:$hitBA[$idB][1]"};
	$besthitBA[$idB] = $hitBA[$idB][1];
	for $hit (2..$hitnBA[$idB]){
	    if ($bestscore - $scoreBA{"$idB:$hitBA[$idB][$hit]"} <= $grey_zone){
		$besthitBA[$idB] .= " $hitBA[$idB][$hit]";
	    }
	    else {last;}
	}
	undef $is_besthitBA[$idB]; # Create index that we can check later
	grep (vec($is_besthitBA[$idB],$_,1) = 1, split(/ /,$besthitBA[$idB]));
#    printf ("besthitBA[%d] = %d\n",$idA,$besthitAB[$idA]);
    }      
    
    if ($show_times){
	($user_time,,,) = times;
	printf ("Reading and sorting homologs took %.2f seconds\n", ($user_time - $prev_time));
	$prev_time = $user_time;
    }
    
######################################################
# Now find orthologs:
######################################################
    $o = 0;
    
    for $i(1..$A){   # For each ID in file A
	if (defined $besthitAB[$i]){
	    @besthits = split(/ /,$besthitAB[$i]);
	    for $hit (@besthits){
		if (vec($is_besthitBA[$hit],$i,1)){
		    ++$o;
		    $ortoA[$o] = $i;
		    $ortoB[$o] = $hit;
		    $ortoS[$o] = $scoreAB{"$i:$hit"}; # Should be equal both ways
#	    --$o if ($ortoS[$o] == $score_cutoff); # Ignore orthologs that are exactly at score_cutoff
		    print "Accept! " if ($debug == 2);
		}
		else {print "        " if ($debug == 2);}
		printf ("%-20s\t%d\t%-20s\t", $nameA[$i], $bestscoreAB[$i], $nameB[$hit]) if ($debug == 2);
		print "$bestscoreBA[$hit]\t$besthitBA[$hit]\n" if ($debug == 2);
	    }
	}   
    }
    print "$o ortholog candidates detected\n" if ($debug);
#####################################################
# Sort orthologs by ID and then by score:
#####################################################

####################################################################################################### Modification by Isabella 2

    # Removed time consuiming bubble sort. Created an index array and sort that according to id and score.
    # The put all clusters on the right place.

    # Create an array used to store the position each element shall have in the final array
    # The elements are initialized with the position numbers
    my @position_index_array = (1..$o);

    # Sort the position list according to id
    my @id_sorted_position_list = sort { ($ortoA[$a]+$ortoB[$a]) <=> ($ortoA[$b] + $ortoB[$b]) } @position_index_array;

    # Sort the list according to score
    my @score_id_sorted_position_list = sort { $ortoS[$b] <=> $ortoS[$a] } @id_sorted_position_list;

    # Create new arrays for the sorted information
    my @new_ortoA;
    my @new_ortoB;
    my @new_orthoS;

   # Add the information to the new arrays in the orer specifeid by the index array
   for (my $index_in_list = 0; $index_in_list < scalar @score_id_sorted_position_list; $index_in_list++) {
	

	my $old_index = $score_id_sorted_position_list[$index_in_list];
	$new_ortoA[$index_in_list + 1] = $ortoA[$old_index];
	$new_ortoB[$index_in_list + 1] = $ortoB[$old_index];
	$new_ortoS[$index_in_list + 1] = $ortoS[$old_index];
   }

    @ortoA = @new_ortoA;
    @ortoB = @new_ortoB;
    @ortoS = @new_ortoS;

    # Use bubblesort to sort ortholog pairs by id
#    for $i(1..($o-1)){ 
#	while(($ortoA[$i]+$ortoB[$i]) > ($ortoA[$i+1] + $ortoB[$i+1])){
#	    $tempA =  $ortoA[$i];
#	    $tempB =  $ortoB[$i];
#	    $tempS =  $ortoS[$i];
#	    
#	    $ortoA[$i] = $ortoA[$i+1];
#	    $ortoB[$i] = $ortoB[$i+1];
#	    $ortoS[$i] = $ortoS[$i+1];
#	    
#	    $ortoA[$i+1] = $tempA;
#	    $ortoB[$i+1] = $tempB;
#	    $ortoS[$i+1] = $tempS;
#	    
#	    --$i if ($i > 1);
#	}
#    }
#
#    # Use bubblesort to sort ortholog pairs by score
#    for $i(1..($o-1)){
#	while($ortoS[$i] < $ortoS[$i+1]){
#	    # Swap places:
#	    $tempA =  $ortoA[$i];
#	    $tempB =  $ortoB[$i];
#	    $tempS =  $ortoS[$i];
#	    
#	    $ortoA[$i] = $ortoA[$i+1];
#	    $ortoB[$i] = $ortoB[$i+1];
#	    $ortoS[$i] = $ortoS[$i+1];
#	    
#	    $ortoA[$i+1] = $tempA;
#	    $ortoB[$i+1] = $tempB;
#	    $ortoS[$i+1] = $tempS;
#	    
#	    --$i if ($i > 1);
#	}
#    }

###################################################################################################### End modification bt Isabella 2

    @all_ortologsA = ();
    @all_ortologsB = ();
    for $i(1..$o){
	push(@all_ortologsA,$ortoA[$i]); # List of all orthologs
	push(@all_ortologsB,$ortoB[$i]);
    }
    undef $is_ortologA; # Create index that we can check later
    undef $is_ortologB;
    grep (vec($is_ortologA,$_,1) = 1, @all_ortologsA);
    grep (vec($is_ortologB,$_,1) = 1, @all_ortologsB);
    
    if ($show_times){
	($user_time,,,) = times;
	printf ("Finding and sorting orthologs took %.2f seconds\n", ($user_time - $prev_time));
	$prev_time = $user_time;
    }
#################################################
# Read in best hits from blast output file AC
#################################################
    if ($use_outgroup){
	$count = 0;
	open AC, "$blast_outputAC" or die "Blast output file A->C is missing\n";
	while (<AC>){
	    chomp;
	    @Fld = split(/\s+/);    # Get query, match and score

            if( scalar @Fld < 9 ){
	       if($Fld[0]=~/done/){
		   print STDERR "AC ok\n";
   	       }
	       next;
            } 

	    $q = $Fld[0];
	    $m = $Fld[1];
	    $idQ = $idA{$q};
	    $idM = $idC{$m};
	    $score = $Fld[2];
	    next unless (vec($is_ortologA,$idQ,1));
	    
	    next if (!overlap_test(@Fld));

	    next if ($score < $score_cutoff);

	    next if ($count and ($q eq $oldq));
	    # Only comes here if this is the best hit:
	    $besthitAC[$idQ] = $idM; 
	    $bestscoreAC[$idQ] = $score;
	    $oldq = $q;
	    ++$count;
	}
	close AC;
#################################################
# Read in best hits from blast output file BC
#################################################
	$count = 0;
	open BC, "$blast_outputBC" or die "Blast output file B->C is missing\n";
	while (<BC>){
	    chomp;
	    @Fld = split(/\s+/);    # Get query, match and score

            if( scalar @Fld < 9 ){
	       if($Fld[0]=~/done/){
		   print STDERR "BC ok\n";
   	       }
	       next;
            } 

	    $q = $Fld[0];
	    $m = $Fld[1];
	    $idQ = $idB{$q};
	    $idM = $idC{$m};
	    $score = $Fld[2];
	    next unless (vec($is_ortologB,$idQ,1));
	    
	    next if (!overlap_test(@Fld));

	    next if ($score < $score_cutoff);

	    next if ($count and ($q eq $oldq));
	    # Only comes here if this is the best hit:
	    $besthitBC[$idQ] = $idM;
	    $bestscoreBC[$idQ] = $score;
	    $oldq = $q;
	    ++$count;
	}
	close BC;
################################
# Detect rooting problems
################################
	$rejected = 0;
	@del = ();
	$file = "rejected_sequences." . $fasta_seq_fileC;
	open OUTGR, ">$file";
	for $i (1..$o){
	    $diff1 = $diff2 = 0;
	    $idA = $ortoA[$i];
	    $idB = $ortoB[$i];
	    $diff1 = $bestscoreAC[$idA] - $ortoS[$i];
	    $diff2 = $bestscoreBC[$idB] - $ortoS[$i];
	    if ($diff1 > $outgroup_cutoff){
		print OUTGR "Ortholog pair $i ($nameA[$idA]-$nameB[$idB]). 
   $nameA[$idA] from $fasta_seq_fileA is closer to $nameC[$besthitAC[$idA]] than to $nameB[$idB]\n";
		print OUTGR "   $ortoS[$i] < $bestscoreAC[$idA] by $diff1\n";
	    }
	    if ($diff2 > $outgroup_cutoff){
		print OUTGR "Ortholog pair $i ($nameA[$idA]-$nameB[$idB]). 
   $nameB[$idB] from $fasta_seq_fileB is closer to $nameC[$besthitBC[$idB]] than to $nameA[$idA]\n";
		print OUTGR "   $ortoS[$i] < $bestscoreBC[$idB] by $diff2\n";
	    }
	    if (($diff1 > $outgroup_cutoff) or ($diff2 > $outgroup_cutoff)){
		++$rejected;
		$del[$i] = 1;
	    }
	}
	print "Number of rejected groups: $rejected (outgroup sequence was closer by more than $outgroup_cutoff bits)\n";
	close OUTGR;
    } # End of $use_outgroup
################################
# Read inside scores from AA
################################
    $count = 0;
    $max_hit = 0;
    open AA, "$blast_outputAA" or die "Blast output file A->A is missing\n";
    while (<AA>) {
	chomp;                  # strip newline
	
	@Fld = split(/\s+/);    # Get query and match names

	if( scalar @Fld < 9 ){
	    if($Fld[0]=~/done/){
		print STDERR "AA ok\n";
	    }
	    next;
	} 

	$q = $Fld[0];
	$m = $Fld[1];
	$score = $Fld[2];
	next unless (vec($is_ortologA,$idA{$q},1));
	
	next if (!overlap_test(@Fld));

	next if ($score < $score_cutoff);

	if(!$count || $q ne $oldq){ # New query 
	    $max_hit = $hit if ($hit > $max_hit);
	    $hit = 0;
	    $oldq = $q;
	}   
	++$hit;
	++$count;
	$scoreAA{"$idA{$q}:$idA{$m}"}  = int($score + 0.5);
	$hitAA[$idA{$q}][$hit] = int($idA{$m});
	$hitnAA[$idA{$q}] = $hit;
    }
    close AA;
    if ($output){
	print OUTPUT "$count $fasta_seq_fileA-$fasta_seq_fileA matches\n";
    }
################################
# Read inside scores from BB
################################
    $count = 0;
    open BB, "$blast_outputBB" or die "Blast output file B->B is missing\n";
    while (<BB>) {
	chomp;                  # strip newline
	
	@Fld = split(/\s+/);    # Get query and match names

	if( scalar @Fld < 9 ){
	    if($Fld[0]=~/done/){
		print STDERR "BB ok\n";
	    }
	    next;
	} 

	$q = $Fld[0];
	$m = $Fld[1];
	$score = $Fld[2];
	next unless (vec($is_ortologB,$idB{$q},1));
	
	next if (!overlap_test(@Fld));

	next if ($score < $score_cutoff);
	
	if(!$count || $q ne $oldq){ # New query 
	    $max_hit = $hit if ($hit > $max_hit);
	    $oldq = $q;
	    $hit = 0;
	}
	++$count;
	++$hit;
	$scoreBB{"$idB{$q}:$idB{$m}"} = int($score + 0.5);
	$hitBB[$idB{$q}][$hit] = int($idB{$m});
	$hitnBB[$idB{$q}] = $hit;
    }
    close BB;
    if ($output){
	print OUTPUT "$count $fasta_seq_fileB-$fasta_seq_fileB matches\n";
    }
    if ($show_times){
	($user_time,,,) = times;
	printf ("Reading paralogous hits took %.2f seconds\n", ($user_time - $prev_time));
	$prev_time = $user_time;
    }
    print "Maximum number of hits per sequence was $max_hit\n" if ($debug);
#####################################################
# Find paralogs:
#####################################################
    for $i(1..$o){
	$merge[$i] = 0;
	next if($del[$i]); # If outgroup species was closer to one of the seed orthologs
	$idA = $ortoA[$i];
	$idB = $ortoB[$i];
	local @membersA = ();
	local @membersB = ();
	
	undef $is_paralogA[$i];
	undef $is_paralogB[$i];
	
	print "$i: Ortholog pair $nameA[$idA] and $nameB[$idB]. $hitnAA[$idA] hits for A and $hitnBB[$idB] hits for B\n"  if ($debug);
	# Check if current ortholog is already clustered:
	for $j(1..($i-1)){
	    # Overlap type 1: Both orthologs already clustered here -> merge  
	    if ((vec($is_paralogA[$j],$idA,1)) and (vec($is_paralogB[$j],$idB,1))){
		$merge[$i] = $j;
		print "Merge CASE 1: group $i ($nameB[$idB]-$nameA[$idA]) and $j ($nameB[$ortoB[$j]]-$nameA[$ortoA[$j]])\n" if ($debug);
		last;
	    }
	    # Overlap type 2: 2 competing ortholog pairs -> merge
	    elsif (($ortoS[$j] - $ortoS[$i] <= $grey_zone)
		   and (($ortoA[$j] == $ortoA[$i]) or ($ortoB[$j] == $ortoB[$i]))
#       and ($paralogsA[$j])
		   ){ # The last condition is false if the previous cluster has been already deleted
		$merge[$i] = $j;
		print "Merge CASE 2: group $i ($nameA[$ortoA[$i]]-$nameB[$ortoB[$i]]) and $j ($nameA[$ortoA[$j]]-$nameB[$ortoB[$j]])\n" if ($debug);
		last;
	    }
	    # Overlap type 3: DELETE One of the orthologs belongs to some much stronger cluster -> delete
	    elsif (((vec($is_paralogA[$j],$idA,1)) or (vec($is_paralogB[$j],$idB,1))) and
		   ($ortoS[$j] - $ortoS[$i] > $score_cutoff)){
		print "Delete CASE 3: Cluster $i -> $j, score $ortoS[$i] -> $ortoS[$j], ($nameA[$ortoA[$j]]-$nameB[$ortoB[$j]])\n" if ($debug);
		$merge[$i]= -1; # Means - do not add sequences to this cluster
		$paralogsA[$i] = "";
		$paralogsB[$i] = "";
		last;
	    }
	    # Overlap type 4: One of the orthologs is close to the center of other cluster
	    elsif (((vec($is_paralogA[$j],$idA,1)) and ($confPA[$idA] > $group_overlap_cutoff)) or
		   ((vec($is_paralogB[$j],$idB,1)) and ($confPB[$idB] > $group_overlap_cutoff))){
		print "Merge CASE 4: Cluster $i -> $j, score $ortoS[$i] -> $ortoS[$j], ($nameA[$ortoA[$j]]-$nameB[$ortoB[$j]])\n" if ($debug);
		$merge[$i] = $j;
		last;
	    }
	    # Overlap type 5:
	    # All clusters that were overlapping, but not catched by previous "if" statements will be DIVIDED!
	} 
	next if ($merge[$i] < 0); # This cluster should be deleted
##### Check for paralogs in A
	$N = $hitnAA[$idA];
	for $j(1..$N){
	    $hitID = $hitAA[$idA][$j]; # hit of idA 
#      print "Working with $nameA[$hitID]\n" if ($debug == 2);
	    # Decide whether this hit is inside the paralog circle:
	    if ( ($idA == $hitID) or ($scoreAA{"$idA:$hitID"} >= $bestscoreAB[$idA]) and 
		($scoreAA{"$idA:$hitID"} >= $bestscoreAB[$hitID])){
		if ($debug == 2){
		    print "   Paralog candidates: ";
		    printf ("%-20s: %-20s", $nameA[$idA], $nameA[$hitID]);
		    print "\t$scoreAA{\"$idA:$hitID\"} : $bestscoreAB[$idA] : $bestscoreAB[$hitID]\n";
		}
		$paralogs = 1;
		if ($scoreAA{"$idA:$idA"} == $ortoS[$i]){
		    if ($scoreAA{"$idA:$hitID"} == $scoreAA{"$idA:$idA"}){
			$conf_here = 1.0; # In the center
		    }
		    else{
			$conf_here = 0.0; # On the border
		    }
		}
		else {
		    $conf_here = ($scoreAA{"$idA:$hitID"} - $ortoS[$i]) /
			($scoreAA{"$idA:$idA"} - $ortoS[$i]);
		}
		# Check if this paralog candidate is already clustered in other clusters
		for $k(1..($i-1)){ 
		    if (vec($is_paralogA[$k],$hitID,1)){ # Yes, found in cluster $k
			if($debug == 2){
			    print "      $nameA[$hitID] is already in cluster $k, together with:";
			    print " $nameA[$ortoA[$k]] and $nameB[$ortoB[$k]] ";
			    print "($scoreAA{\"$ortoA[$k]:$hitID\"})";         
			}
			if (($confPA[$hitID] >= $conf_here) and 
			    ($j != 1)){ # The seed ortholog CAN NOT remain there
			    print " and remains there.\n" if ($debug == 2);
			    $paralogs = 0; # No action
			}
			else { # Ortholog of THIS cluster is closer than ortholog of competing cluster $k 
			    print " and should be moved here!\n" if ($debug == 2); # Remove from other cluster, add to this cluster
			    @membersAK = split(/ /, $paralogsA[$k]); # This array contains IDs
			    $paralogsA[$k] = "";# Remove all paralogs from cluster $k
				@tmp = ();
			    for $m(@membersAK){   
				push(@tmp,$m) if ($m != $hitID); # Put other members back  
			    }  
			    $paralogsA[$k] = join(' ',@tmp);
			    undef $is_paralogA[$k]; # Create index that we can check later
			    grep (vec($is_paralogA[$k],$_,1) = 1, @tmp);
			}
			last;
		    }
		}
		next if (! $paralogs); # Skip that paralog - it is already in cluster $k
		push (@membersA,$hitID); # Add this hit to paralogs of A 
	    } 
	}
	# Calculate confidence values now:
	@tmp = ();
	for $idP (@membersA){ # For each paralog calculate conf value
	    if($scoreAA{"$idA:$idA"} == $ortoS[$i]){
		if ($scoreAA{"$idA:$idP"} == $scoreAA{"$idA:$idA"}){
		    $confPA[$idP] = 1.00;
		}
		else{ 
		    $confPA[$idP] = 0.00;
		}
	    }
	    else{ 
		$confPA[$idP] = ($scoreAA{"$idA:$idP"} - $ortoS[$i]) / 
		    ($scoreAA{"$idA:$idA"} - $ortoS[$i]);
	    }
	    push (@tmp, $idP) if ($confPA[$idP] >= $conf_cutoff); # If one wishes to use only significant paralogs
	}
	@membersA = @tmp;
	########### Merge if necessary:
	if ($merge[$i] > 0){ # Merge existing cluster with overlapping cluster
	    @tmp = split(/ /,$paralogsA[$merge[$i]]);      
	    for $m (@membersA){
		push (@tmp, $m)  unless (vec($is_paralogA[$merge[$i]],$m,1));
	    }
	    $paralogsA[$merge[$i]] = join(' ',@tmp);
	    undef $is_paralogA[$merge[$i]];
	    grep (vec($is_paralogA[$merge[$i]],$_,1) = 1, @tmp); # Refresh index of paralog array
	}
	######### Typical new cluster:
	else{  # Create a new cluster
	    $paralogsA[$i] = join(' ',@membersA);
	    undef $is_paralogA; # Create index that we can check later
	    grep (vec($is_paralogA[$i],$_,1) = 1, @membersA);
	}  
##### The same procedure for species B:   
	$N = $hitnBB[$idB];
	for $j(1..$N){
	    $hitID = $hitBB[$idB][$j];
#      print "Working with $nameB[$hitID]\n" if ($debug == 2);
	    if ( ($idB == $hitID) or ($scoreBB{"$idB:$hitID"} >= $bestscoreBA[$idB]) and 
		($scoreBB{"$idB:$hitID"} >= $bestscoreBA[$hitID])){
		if ($debug == 2){
		    print "   Paralog candidates: ";
		    printf ("%-20s: %-20s", $nameB[$idB], $nameB[$hitID]);
		    print "\t$scoreBB{\"$idB:$hitID\"} : ";
		    print "$bestscoreBA[$idB] : $bestscoreBA[$hitID]\n";
		}         
		$paralogs = 1;
		if ($scoreBB{"$idB:$idB"} == $ortoS[$i]){
		    if ($scoreBB{"$idB:$hitID"} == $scoreBB{"$idB:$idB"}){
			$conf_here = 1.0;
		    }
		    else{
			$conf_here = 0.0;
		    }
		}
		else{
		    $conf_here = ($scoreBB{"$idB:$hitID"} - $ortoS[$i]) /
			($scoreBB{"$idB:$idB"} - $ortoS[$i]);
		}
		
		# Check if this paralog candidate is already clustered in other clusters
		for $k(1..($i-1)){ 
		    if (vec($is_paralogB[$k],$hitID,1)){ # Yes, found in cluster $k
			if($debug == 2){
			    print "      $nameB[$hitID] is already in cluster $k, together with:";
			    print " $nameB[$ortoB[$k]] and $nameA[$ortoA[$k]] ";
			    print "($scoreBB{\"$ortoB[$k]:$hitID\"})";
			}
			if (($confPB[$hitID] >= $conf_here) and
			    ($j != 1)){ # The seed ortholog CAN NOT remain there
			    print " and remains there.\n" if ($debug == 2);
			    $paralogs = 0; # No action
			}
			else { # Ortholog of THIS cluster is closer than ortholog of competing cluster $k 
			    print " and should be moved here!\n" if ($debug == 2); # Remove from other cluster, add to this cluster
			    @membersBK = split(/ /, $paralogsB[$k]); # This array contains names, not IDs
			    $paralogsB[$k] = "";
			    @tmp = ();
			    for $m(@membersBK){   
				push(@tmp,$m) if ($m != $hitID); # Put other members back  
			    }  
			    $paralogsB[$k] = join(' ',@tmp);
			    undef $is_paralogB[$k]; # Create index that we can check later
			    grep (vec($is_paralogB[$k],$_,1) = 1, @tmp);
			}
			last; # Don't search in other clusters
		    }
		}
		next if (! $paralogs); # Skip that paralog - it is already in cluster $k
		push (@membersB,$hitID);
	    }
	}
	# Calculate confidence values now:
	@tmp = ();
	for $idP (@membersB){ # For each paralog calculate conf value
	    if($scoreBB{"$idB:$idB"} == $ortoS[$i]){
		if ($scoreBB{"$idB:$idP"} == $scoreBB{"$idB:$idB"}){
		    $confPB[$idP] = 1.0;
		}
		else{
		    $confPB[$idP] = 0.0;
		}
	    }   
	    else{
		$confPB[$idP] = ($scoreBB{"$idB:$idP"} - $ortoS[$i]) / 
		    ($scoreBB{"$idB:$idB"} - $ortoS[$i]);
	    }
	    push (@tmp, $idP) if ($confPB[$idP] >= $conf_cutoff); # If one wishes to use only significant paralogs
	}   
	@membersB = @tmp;
	########### Merge if necessary:
	if ($merge[$i] > 0){ # Merge existing cluster with overlapping cluster
	    @tmp = split(/ /,$paralogsB[$merge[$i]]);      
	    for $m (@membersB){
		push (@tmp, $m)  unless (vec($is_paralogB[$merge[$i]],$m,1));
	    }
	    $paralogsB[$merge[$i]] = join(' ',@tmp);
	    undef $is_paralogB[$merge[$i]];
	    grep (vec($is_paralogB[$merge[$i]],$_,1) = 1, @tmp); # Refresh index of paralog array
	}
	######### Typical new cluster:
	else{  # Create a new cluster
	    $paralogsB[$i] = join(' ',@membersB);
	    undef $is_paralogB; # Create index that we can check later
	    grep (vec($is_paralogB[$i],$_,1) = 1, @membersB);
	}
    }
    if ($show_times){
	($user_time,,,) = times;
	printf ("Finding in-paralogs took %.2f seconds\n", ($user_time - $prev_time));
	$prev_time = $user_time;
    }
#####################################################
    &clean_up(1);
####################################################
# Find group for orphans. If cluster contains only one member, find where it should go:
    for $i (1..$o){ 
	@membersA = split(/ /, $paralogsA[$i]);
	@membersB = split(/ /, $paralogsB[$i]);
	$na = @membersA;
	$nb = @membersB;
	if (($na == 0) and $nb){
	    print "Warning: empty A cluster $i\n";
	    for $m (@membersB){
		$bestscore = 0;
		$bestgroup = 0;
		$bestmatch = 0;
		for $j (1..$o) {
		    next if ($i == $j); # Really need to check against all 100% members of the group.
		    @membersBJ = split(/ /, $paralogsB[$j]);
		    for $k (@membersBJ){
			next if ($confPB[$k] != 1); # For all 100% in-paralogs
			$score = $scoreBB{"$m:$k"};
			if ($score > $bestscore){
			    $bestscore = $score;
			    $bestgroup = $j;
			    $bestmatch = $k;
			}
		    }
		}
		print "Orphan $nameB[$m] goes to group $bestgroup with $nameB[$bestmatch]\n" ;
		@members = split(/ /, $paralogsB[$bestgroup]);
		push (@members, $m);
		$paralogsB[$bestgroup] = join(' ',@members);
		$paralogsB[$i] = "";
		undef $is_paralogB[$bestgroup];
		undef $is_paralogB[$i];
		grep (vec($is_paralogB[$bestgroup],$_,1) = 1, @members); # Refresh index of paralog array
#		 grep (vec($is_paralogB[$i],$_,1) = 1, ());
	    }
	}
	if ($na and ($nb == 0)){
	    print "Warning: empty B cluster $i\n";
	    for $m (@membersA){	  
		$bestscore = 0;
		$bestgroup = 0;
		$bestmatch = 0;
		for $j (1..$o) {
		    next if ($i == $j);
		    @membersAJ = split(/ /, $paralogsA[$j]);
		    for $k (@membersAJ){
			next if ($confPA[$k] != 1); # For all 100% in-paralogs
			$score = $scoreAA{"$m:$k"};
			if ($score > $bestscore){
			    $bestscore = $score;
			    $bestgroup = $j;
			    $bestmatch = $k;
			}
		    }
		}
		print "Orphan $nameA[$m] goes to group $bestgroup with $nameA[$bestmatch]\n";
		@members = split(/ /, $paralogsA[$bestgroup]);
		push (@members, $m);
		$paralogsA[$bestgroup] = join(' ',@members);
		$paralogsA[$i] = "";
		undef $is_paralogA[$bestgroup];
		undef $is_paralogA[$i];
		grep (vec($is_paralogA[$bestgroup],$_,1) = 1, @members); # Refresh index of paralog array
#	     grep (vec($is_paralogA[$i],$_,1) = 1, ());
	    }
	}
    }
    
    &clean_up(1);
###################
    $htmlfile = "orthologs." . $ARGV[0] . "-" . $ARGV[1] . ".html";
    if ($html){
	open HTML, ">$htmlfile" or warn "Could not write to HTML file $filename\n";
    }
    
    
    if ($output){
	print OUTPUT "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";
	print OUTPUT "$o groups of orthologs\n";
	print OUTPUT "$totalA in-paralogs from $fasta_seq_fileA\n";
	print OUTPUT "$totalB in-paralogs from $fasta_seq_fileB\n";
	print OUTPUT "Grey zone $grey_zone bits\n";
	print OUTPUT "Score cutoff $score_cutoff bits\n";
	print OUTPUT "In-paralogs with confidence less than $conf_cutoff not shown\n";
	print OUTPUT "Sequence overlap cutoff $seq_overlap_cutoff\n";
	print OUTPUT "Group merging cutoff $group_overlap_cutoff\n";
	print OUTPUT "Scoring matrix $matrix\n"; 
	print OUTPUT "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";
    }
    if ($html){
	print HTML "<pre>\n";
	print HTML "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";
	print HTML "$o groups of orthologs\n";
	print HTML "$totalA in-paralogs from $fasta_seq_fileA\n";
	print HTML "$totalB in-paralogs from $fasta_seq_fileB\n";
	print HTML "Grey zone $grey_zone bits\n";
	print HTML "Score cutoff $score_cutoff bits\n";
	print HTML "In-paralogs with confidence less than $conf_cutoff not shown\n";
	print HTML "Sequence overlap cutoff $seq_overlap_cutoff\n";
	print HTML "Group merging cutoff $group_overlap_cutoff\n";
	print HTML "Scoring matrix $matrix\n";
	print HTML "\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\n";
    }
# ##############################################################################
# Check for alternative orthologs, sort paralogs by confidence and print results
# ##############################################################################
    if ($use_bootstrap and $debug){
	open FF, ">BS_vs_bits" or warn "Could not write to file BS_vs_bits\n";
    }
    for $i(1..$o){
	@membersA = split(/ /, $paralogsA[$i]);
	@membersB = split(/ /, $paralogsB[$i]);		 
	$message = "";
	$htmlmessage = "";
	
	$idB = $ortoB[$i];
	$nB = $hitnBA[$idB];
	for $idA(@membersA){
	    next if ($confPA[$idA] != 1.0);
	    $nA = $hitnAB[$idA];
	    $confA[$i] = $ortoS[$i]; # default
	    $bsA[$idA] = 1.0;
	    ##############
	    for $j(1..$nB){
		$idH = $hitBA[$idB][$j];
		################ Some checks for alternative orthologs:
		# 1. Don't consider sequences that are already in this cluster
		next if (vec($is_paralogA[$i],$idH,1));
		next if ($confPA[$idH] > 0); # If $conf_cutoff > 0 idH might be incide circle, but not paralog
		
		# 2. Check if candidate for alternative ortholog is already clustered in stronger clusters
		$in_other_cluster = 0;
		for $k(1..($i-1)){ # Check if current ortholog is already clustered
		    if (vec($is_paralogA[$k],$idH,1)){
			$in_other_cluster = $k;
			last;
		    }
		}
#		 next if ($in_other_cluster); # This hit is clustered in cluster $k. It cannot be alternative ortholog 
		
		# 3. The best hit of candidate ortholog should be ortoA or at least to belong into this cluster
		@besthits = split (/ /,$besthitAB[$idH]);
		$this_family = 0;
		for $bh (@besthits){
		    $this_family = 1 if ($idB == $bh);
		}
#		 next unless ($this_family); # There was an alternative BA match but it's best match did not belong here
		################# Done with checks - if sequence passed, then it could be an alternative ortholog
		$confA[$i] = $ortoS[$i] - $scoreBA{"$idB:$idH"};
		if ($use_bootstrap){ 
		    if ($confA[$i] < $ortoS[$i]){ # Danger zone - check for bootstrap
			$bsA[$idA] = &bootstrap($fasta_seq_fileB,$idB,$idA,$idH);
		    }
		    else { 
			$bsA[$idA] = 1.0;
		    }
		}
		last;
	    }
	    $message .= sprintf("Bootstrap support for %s as seed ortholog is %d%%.", $nameA[$idA], 100*$bsA[$idA]);
	    $message .= sprintf(" Alternative seed ortholog is %s (%d bits away from this cluster)", $nameA[$idH], $confA[$i]) if ($bsA[$idA] < 0.75);
	    $message .= sprintf("\n");
	    if ($html){
		if ($bsA[$idA] < 0.75){
		    $htmlmessage .= sprintf("<font color=\"red\">"); 			
		}
		elsif ($bsA[$idA] < 0.95){
		    $htmlmessage .= sprintf("<font color=\"\#FFCC00\">");
		}  
		else {
		    $htmlmessage .= sprintf("<font color=\"green\">");
		}  
		$htmlmessage .= sprintf("Bootstrap support for %s as seed ortholog is %d%%.\n", $nameA[$idA], 100*$bsA[$idA]);
		$htmlmessage .= sprintf("Alternative seed ortholog is %s (%d bits away from this cluster)\n", $nameA[$idH], $confA[$i]) if ($bsA[$idA] < 0.75);
		$htmlmessage .= sprintf("</font>");
	    } 
	    printf (FF "%s\t%d\t%d\n", $nameA[$idA], $confA[$i], 100*$bsA[$idA]) if ($use_bootstrap and $debug); 
	}
	########
	$idA = $ortoA[$i];
	$nA = $hitnAB[$idA];
	for $idB(@membersB){
	    next if ($confPB[$idB] != 1.0);
	    $nB = $hitnBA[$idB];
	    $confB[$i] = $ortoS[$i]; # default
	    $bsB[$idB] = 1.0;
	    
	    for $j(1..$nA){ # For all AB hits of given ortholog
		$idH = $hitAB[$idA][$j];
		# ############### Some checks for alternative orthologs:
		# 1. Don't consider sequences that are already in this cluster
		next if (vec($is_paralogB[$i],$idH,1));
		next if ($confPB[$idH] > 0); # If $conf_cutoff > 0 idH might be incide circle, but not paralog
		
		# 2. Check if candidate for alternative ortholog is already clustered in stronger clusters
		$in_other_cluster = 0;
		for $k(1..($i-1)){
		    if (vec($is_paralogB[$k],$idH,1)){
			$in_other_cluster = $k;
			last; # out from this cycle
		    }
		}
#		 next if ($in_other_cluster); # This hit is clustered in cluster $k. It cannot be alternative ortholog 
		
		# 3. The best hit of candidate ortholog should be ortoA
		@besthits = split (/ /,$besthitBA[$idH]);
		$this_family = 0;
		for $bh (@besthits){
		    $this_family = 1 if ($idA == $bh);
		}
#		 next unless ($this_family); # There was an alternative BA match but it's best match did not belong here
		# ################ Done with checks - if sequence passed, then it could be an alternative ortholog
		$confB[$i] = $ortoS[$i] - $scoreAB{"$idA:$idH"};
		if ($use_bootstrap){
		    if ($confB[$i] < $ortoS[$i]){
			$bsB[$idB] = &bootstrap($fasta_seq_fileA,$idA,$idB,$idH);
		    }
		    else {
			$bsB[$idB] = 1.0;
		    }
		}
		last;
	    }
	    $message .= sprintf("Bootstrap support for %s as seed ortholog is %d%%.", $nameB[$idB], 100*$bsB[$idB]);
	    $message .= sprintf(" Alternative seed ortholog is %s (%d bits away from this cluster)", $nameB[$idH],$confB[$i]) if ($bsB[$idB] < 0.75);
	    $message .= sprintf("\n");
	    if ($html){
		if ($bsB[$idB] < 0.75){
		    $htmlmessage .= sprintf("<font color=\"red\">");
		}      
		elsif ($bsB[$idB] < 0.95){
		    $htmlmessage .= sprintf("<font color=\"\#FFCC00\">");
		}
		else {
		    $htmlmessage .= sprintf("<font color=\"green\">");
		}
		$htmlmessage .= sprintf("Bootstrap support for %s as seed ortholog is %d%%.\n", $nameB[$idB], 100*$bsB[$idB]);
		$htmlmessage .= sprintf("Alternative seed ortholog is %s (%d bits away from this cluster)\n",  $nameB[$idH],$confB[$i]) if ($bsB[$idB] < 0.75);
		$htmlmessage .= sprintf("</font>");
	    }
	    printf (FF "%s\t%d\t%d\n", $nameB[$idB], $confB[$i], 100*$bsB[$idB]) if ($use_bootstrap and $debug);
	}		
	close FF;
	########### Print header ###############
	if ($output){
	    print OUTPUT "___________________________________________________________________________________\n";
	    print OUTPUT "Group of orthologs #" . $i .". Best score $ortoS[$i] bits\n";
		print OUTPUT "Score difference with first non-orthologous sequence - ";
	    printf (OUTPUT "%s:%d   %s:%d\n", $fasta_seq_fileA,$confA[$i],$fasta_seq_fileB,$confB[$i]);
	}
	
	if ($html){
	    print HTML "</pre>\n";
	    print HTML "<hr WIDTH=\"100%\">";
	    print HTML "<h3>";
	    print HTML "Group of orthologs #" . $i .". Best score $ortoS[$i] bits<br>\n";
		print HTML "Score difference with first non-orthologous sequence - ";
	    printf (HTML "%s:%d   %s:%d</h3><pre>\n", $fasta_seq_fileA,$confA[$i],$fasta_seq_fileB,$confB[$i]);			
	}
	########### Sort and print members of A ############
	$nA = @membersA;
	$nB = @membersB;
	$nMAX = ($nA > $nB) ? $nA : $nB;
	# Sort membersA inside the cluster by confidence:
	for $m (0..($nA-1)){
	    while($confPA[$membersA[$m]] < $confPA[$membersA[$m+1]]){
		$temp = $membersA[$m];
		$membersA[$m] = $membersA[$m+1];
		$membersA[$m+1] = $temp;
		--$m if ($m > 1);
	    }
	}
	$paralogsA[$i] = join(' ',@membersA); # Put them back together
	# Sort membersB inside the cluster by confidence:
	for $m (0..($nB-1)){
	    while($confPB[$membersB[$m]] < $confPB[$membersB[$m+1]]){
		$temp = $membersB[$m];
		$membersB[$m] = $membersB[$m+1];
		$membersB[$m+1] = $temp;
		--$m if ($m > 1);
	    }
	}   
	$paralogsB[$i] = join(' ',@membersB); # Put them back together
	# Print to text file and to HTML file
	for $m (0..($nMAX-1)){
	    if ($m < $nA){
		if ($output){
		    printf (OUTPUT "%-20s\t%.2f%%\t\t", $nameA[$membersA[$m]], (100*$confPA[$membersA[$m]]));
		}
		if ($html){
		    print HTML "<B>" if ($confPA[$membersA[$m]] == 1);
		    printf (HTML "%-20s\t%.2f%%\t\t", $nameA[$membersA[$m]], (100*$confPA[$membersA[$m]]));
		    print HTML "</B>" if ($confPA[$membersA[$m]] == 1);
		}
	    }
	    else {
		printf (OUTPUT "%-20s\t%-7s\t\t", "                    ", "       ");
		printf (HTML "%-20s\t%-7s\t\t", "                    ", "       ") if ($html);
	    }
	    if ($m < $nB){
		if ($output){
		    printf (OUTPUT "%-20s\t%.2f%%\n", $nameB[$membersB[$m]], (100*$confPB[$membersB[$m]]));
		}
		if ($html){
		    print HTML "<B>" if ($confPB[$membersB[$m]] == 1);
		    printf (HTML "%-20s\t%.2f%%", $nameB[$membersB[$m]], (100*$confPB[$membersB[$m]]));
		    print HTML "</B>" if ($confPB[$membersB[$m]] == 1);
		    print HTML "\n";
		}
	    }
	    else {
		printf (OUTPUT "%-20s\t%-7s\n", "                    ", "       ") if($output);
		print HTML "\n" if ($html);
	    }
	}
	print OUTPUT $message if ($use_bootstrap and $output);
	print HTML "$htmlmessage" if ($use_bootstrap and $html);
    }
    if ($output) {
      close OUTPUT;
      print "Output saved to file $outputfile\n";
    }
    if ($html){
      close HTML;
      print "HTML output saved to $htmlfile\n";
    }
    
    if ($table){
	$filename = "table." . $ARGV[0] . "-" . $ARGV[1];
	open F, ">$filename" or die;
	print F "OrtoID\tScore\tOrtoA\tOrtoB\n";
	for $i(1..$o){
	    print F "$i\t$ortoS[$i]\t";
	    @members = split(/ /, $paralogsA[$i]);
	    for $m (@members){
		$m =~ s/://g;
		printf (F "%s %.3f ", $nameA[$m], $confPA[$m]);
	    }
	    print F "\t";
	    @members = split(/ /, $paralogsB[$i]);
	    for $m (@members){
		$m =~ s/://g;
		printf (F "%s %.3f ", $nameB[$m], $confPB[$m]);
	    }
	    print F "\n";
	}  
	close F;
	print "Table output saved to $filename\n";
    }
    if ($mysql_table){
	$filename2 = "sqltable." . $ARGV[0] . "-" . $ARGV[1];
	open F2, ">$filename2" or die;
	for $i(1..$o){
	    @membersA = split(/ /, $paralogsA[$i]);
	    for $m (@membersA){
		# $m =~ s/://g;
		if ($use_bootstrap && $bsA[$m]) {
		    printf (F2 "%d\t%d\t%s\t%.3f\t%s\t%d%\n", $i, $ortoS[$i], $ARGV[0], $confPA[$m], $nameA[$m], 100*$bsA[$m]);
		} else {
		    printf (F2 "%d\t%d\t%s\t%.3f\t%s\n", $i, $ortoS[$i], $ARGV[0], $confPA[$m], $nameA[$m]);
		}
	    }     
	    @membersB = split(/ /, $paralogsB[$i]);
	    for $m (@membersB){
		# $m =~ s/://g;
		if ($use_bootstrap && $bsB[$m]) {
		    printf (F2 "%d\t%d\t%s\t%.3f\t%s\t%d%\n", $i, $ortoS[$i], $ARGV[1], $confPB[$m], $nameB[$m], 100*$bsB[$m]);
		}else {
		    printf (F2 "%d\t%d\t%s\t%.3f\t%s\n", $i, $ortoS[$i], $ARGV[1], $confPB[$m], $nameB[$m]);
		}
	    }
	}
	close F2;
	print "mysql output saved to $filename2\n";
    }
    if ($show_times){
      ($user_time,,,) = times;
      printf ("Finding bootstrap values and printing took %.2f seconds\n", ($user_time - $prev_time));
      printf ("The overall execution time: %.2f seconds\n", $user_time);
    }
    if ($run_blast) { 
      unlink "formatdb.log";
      unlink "$fasta_seq_fileA.phr", "$fasta_seq_fileA.pin", "$fasta_seq_fileA.psq";
      unlink "$fasta_seq_fileB.phr", "$fasta_seq_fileB.pin", "$fasta_seq_fileB.psq" if (@ARGV >= 2);
      unlink "$fasta_seq_fileC.phr", "$fasta_seq_fileC.pin", "$fasta_seq_fileC.psq" if ($use_outgroup);   
    }
  }

##############################################################
# Functions:
##############################################################
sub clean_up { # Sort members within cluster and clusters by size
############################################################################################### Modification by Isabella 3

    # Sort on index arrays with perl's built in sort instead of using bubble sort.

    $var = shift;
    $totalA = $totalB = 0;
    # First pass: count members within each cluster
    foreach $i (1..$o) {
	@membersA = split(/ /, $paralogsA[$i]);      
	$clusnA[$i] = @membersA; # Number of members in this cluster
	$totalA += $clusnA[$i];
	$paralogsA[$i] = join(' ',@membersA);
	
	@membersB = split(/ /, $paralogsB[$i]);      
	$clusnB[$i] = @membersB; # Number of members in this cluster
	$totalB += $clusnB[$i];
	$paralogsB[$i] = join(' ',@membersB);
	
	$clusn[$i] =  $clusnB[$i] + $clusnA[$i]; # Number of members in given group
    }

    # Create an array used to store the position each element shall have in the final array
    # The elements are initialized with the position numbers
    my @position_index_array = (1..$o);

    # Sort the position list according to cluster size
    my @cluster_sorted_position_list = sort { $clusn[$b] <=> $clusn[$a]} @position_index_array;

    # Create new arrays for the sorted information
    my @new_paralogsA;
    my @new_paralogsB;
    my @new_is_paralogA;
    my @new_is_paralogB;
    my @new_clusn;
    my @new_ortoS;
    my @new_ortoA;
    my @new_ortoB;


   # Add the information to the new arrays in the orer specifeid by the index array
   for (my $index_in_list = 0; $index_in_list < scalar @cluster_sorted_position_list; $index_in_list++) {
	
	my $old_index = $cluster_sorted_position_list[$index_in_list];
	
	if (!$clusn[$old_index]) {
		$o = (scalar @new_ortoS) - 1;
		last;
	}

	$new_paralogsA[$index_in_list + 1] = $paralogsA[$old_index];
        $new_paralogsB[$index_in_list + 1] = $paralogsB[$old_index];
    	$new_is_paralogA[$index_in_list + 1] = $is_paralogA[$old_index];
    	$new_is_paralogB[$index_in_list + 1] = $is_paralogB[$old_index];
   	$new_clusn[$index_in_list + 1] = $clusn[$old_index];
	$new_ortoA[$index_in_list + 1] = $ortoA[$old_index];
	$new_ortoB[$index_in_list + 1] = $ortoB[$old_index];
	$new_ortoS[$index_in_list + 1] = $ortoS[$old_index];
   }

    @paralogsA = @new_paralogsA;
    @paralogsB = @new_paralogsB;
    @is_paralogA = @new_is_paralogA;
    @is_paralogB = @new_is_paralogB;
    @clusn = @new_clusn;
    @ortoS = @new_ortoS;
    @ortoA = @new_ortoA;
    @ortoB = @new_ortoB;

    # Create an array used to store the position each element shall have in the final array
    # The elements are initialized with the position numbers
    @position_index_array = (1..$o);

    # Sort the position list according to score
    @score_sorted_position_list = sort { $ortoS[$b] <=> $ortoS[$a] } @position_index_array;

    # Create new arrays for the sorted information
    my @new_paralogsA2 = ();
    my @new_paralogsB2 = ();
    my @new_is_paralogA2 = ();
    my @new_is_paralogB2 = ();
    my @new_clusn2 = ();
    my @new_ortoS2 = ();
    my @new_ortoA2 = ();
    my @new_ortoB2 = ();

   # Add the information to the new arrays in the orer specifeid by the index array
   for (my $index_in_list = 0; $index_in_list < scalar @score_sorted_position_list; $index_in_list++) {
	
	my $old_index = $score_sorted_position_list[$index_in_list];
	$new_paralogsA2[$index_in_list + 1] = $paralogsA[$old_index];
        $new_paralogsB2[$index_in_list + 1] = $paralogsB[$old_index];
    	$new_is_paralogA2[$index_in_list + 1] = $is_paralogA[$old_index];
    	$new_is_paralogB2[$index_in_list + 1] = $is_paralogB[$old_index];
   	$new_clusn2[$index_in_list + 1] = $clusn[$old_index];
	$new_ortoA2[$index_in_list + 1] = $ortoA[$old_index];
	$new_ortoB2[$index_in_list + 1] = $ortoB[$old_index];
	$new_ortoS2[$index_in_list + 1] = $ortoS[$old_index];
   }

    @paralogsA = @new_paralogsA2;
    @paralogsB = @new_paralogsB2;
    @is_paralogA = @new_is_paralogA2;
    @is_paralogB = @new_is_paralogB2;
    @clusn = @new_clusn2;
    @ortoS = @new_ortoS2;
    @ortoA = @new_ortoA2;
    @ortoB = @new_ortoB2;

#################################################################################### End modification by Isabella 3

}
sub bootstrap{
    my $species = shift;
    my $seq_id1 = shift; # Query ID from $species
    my $seq_id2 = shift; # Best hit ID from other species
    my $seq_id3 = shift; # Second best hit
    # Retrieve sequence 1 from $species and sequence 2 from opposite species
    my $significance = 0.0;
    
    if ($species eq $fasta_seq_fileA){
	$file1 = $fasta_seq_fileA;
	$file2 = $fasta_seq_fileB;
    }
    elsif ($species eq $fasta_seq_fileB){
	$file1 = $fasta_seq_fileB;
	$file2 = $fasta_seq_fileA;
    }
    else {
	print "Bootstrap values for ortholog groups are not calculated\n";
	return 0;
    }

    open A, $file1 or die;
    $id = 0;
    $print_this_seq = 0;
    $seq1 = "";
    $seq2 = "";

    $query_file = $seq_id1 . ".faq";                                                                              
    open Q, ">$query_file" or die; 

    while (<A>){
	if(/^\>/){
	    ++$id;
	    $print_this_seq = ($id == $seq_id1)?1:0;
	}
	print Q if ($print_this_seq);
    }
    close A;
    close Q;
    ###
    open B, $file2 or die;
    $db_file = $seq_id2 . ".fas";
    open DB, ">$db_file" or die;
    $id = 0;
    $print_this_seq = 0;

    while (<B>){
	if(/^\>/){
	    ++$id;
	    $print_this_seq = (($id == $seq_id2) or ($id == $seq_id3))?1:0;
	}
	print DB if ($print_this_seq);
    }
    close B;
    close DB;
    
    system "$formatdb -i $db_file";
    # Use soft masking in 1-pass mode for simplicity.
    system "$blastall -F\"m S\" -i $query_file -z 5000000 -d $db_file -p blastp -M $matrix -m7 | ./$blastParser 0 -a > $seq_id2.faa";

    # Note: Changed score cutoff 50 to 0 for blast2faa.pl (060402).
    # Reason: after a cluster merger a score can be less than the cutoff (50) 
    # which will remove the sequence in blast2faa.pl.  The bootstrapping will 
    # then fail.
    # AGAIN, updaye
    
    if (-s("$seq_id2.faa")){

	system("java -jar $seqstat -m $matrix -n 1000 -i $seq_id2.faa > $seq_id2.bs"); # Can handle U, u

	if (-s("$seq_id2.bs")){
	    open BS, "$seq_id2.bs" or die "pac failed\n";
	    $_ = <BS>;
	    ($dummy1,$dummy2,$dummy3,$dummy4,$significance) = split(/\s+/);
	    close BS;	
	}
	else{
	    print STDERR "pac failed\n"; # if ($debug);
	    $significance = -0.01;
	}	
    }
    else{
	print STDERR "blast2faa for $query_file / $db_file failed\n"; # if ($debug);                                            
	$significance = 0.0; 
    }
    
    unlink "$seq_id2.fas", "$seq_id2.faa", "$seq_id2.bs", "$seq_id1.faq"; 
    unlink "formatdb.log", "$seq_id2.fas.psq", "$seq_id2.fas.pin", "$seq_id2.fas.phr";
    
    return $significance;
}

sub overlap_test{
        my @Fld = @_;

	# Filter out fragmentary hits by:
	# Ignore hit if aggregate matching area covers less than $seq_overlap_cutoff of sequence.
	# Ignore hit if local matching segments cover less than $segment_coverage_cutoff of sequence.
	#
	# $Fld[3] and $Fld[4] are query and subject lengths.
	# $Fld[5] and $Fld[6] are lengths of the aggregate matching region on query and subject. (From start of first matching segment to end of last matching segment).
	# $Fld[7] and $Fld[8] are local matching length on query and subject (Sum of all segments length's on query).

	$retval = 1;
#	if ($Fld[3] >= $Fld[4]) {
		if ($Fld[5] < ($seq_overlap_cutoff * $Fld[3])) {$retval = 0};
		if ($Fld[7] < ($segment_coverage_cutoff * $Fld[3])) {$retval = 0};
#	} 
	
#	if ($Fld[4] >= $Fld[3]) { 
		if ($Fld[6] < ($seq_overlap_cutoff * $Fld[4])) {$retval = 0};
		if ($Fld[8] < ($segment_coverage_cutoff * $Fld[4])) {$retval = 0};
#	}
	
	# print "$Fld[3] $Fld[5] $Fld[7]; $Fld[4] $Fld[6] $Fld[8]; retval=$retval\n";

	return $retval;
}

sub do_blast {
  if ($blast_two_passes) {
    do_blast_2pass(@_);
  } else {
    do_blast_1pass(@_);
  }
}

sub do_blast_1pass {
  my @Fld = @_;
  
  # $Fld [0] is query
  # $Fld [1] is database
  # $Fld [2] is query size
  # $Fld [3] is database size
  # $Fld [4] is output name
  
  # Use soft masking (low complexity masking by SEG in search phase, not in alignment phase). 
  # system ("$blastall -F\"m S\" -i $Fld[0] -d $Fld[1] -p blastp -v $Fld[3] -b $Fld[3] -M $matrix -z 5000000 -m7 | ./$blastParser $score_cutoff > $Fld[4]");
  # die "$ghostz aln -i $Fld[0] -d $Fld[1] -o ghostz.$Fld[4] -a $ncpu ; perl $ghostParser $Fld[0] $Fld[1] ghostz.$Fld[4] > $Fld[4]\n";
  system ("$ghostz aln -i $Fld[0] -d $Fld[1] -o ghostz.$Fld[4] -a $ncpu ; perl $ghostParser $Fld[0] $Fld[1] ghostz.$Fld[4] > $Fld[4]");
}

sub do_blast_2pass {

	my @Fld = @_;

	# $Fld [0] is query
	# $Fld [1] is database
	# $Fld [2] is query size
	# $Fld [3] is database size
	# $Fld [4] is output name

	# assume the script has already formatted the database
	# we will now do 2-pass approach

	# load sequences

	%sequencesA = ();
	%sequencesB = ();

	open (FHA, $Fld [0]);
	while (<FHA>) {

		$aLine = $_;
		chomp ($aLine);

		$seq = "";

		if ($aLine =~ />/) {
			@words = split (/\s/, $aLine);
			$seqID = $words[0];
			$sequencesA {$seqID} = "";
		}
		else {
			$sequencesA {$seqID} = $sequencesA {$seqID}.$aLine;
		}		
	}
	close (FHA);

	open (FHB, $Fld [1]);
	while (<FHB>) {
		$aLine = $_;
		chomp ($aLine);

		$seq = "";

		if ($aLine =~ />/) {
			@words = split (/\s/, $aLine);
			$seqID = $words[0];
			$sequencesB {$seqID} = "";
		}
		else {
			$sequencesB {$seqID} = $sequencesB {$seqID}.$aLine;
		}		
	}
	close (FHB);

	# Do first pass with compositional adjustment on and soft masking.  
	# This efficiently removes low complexity matches but truncates alignments,
	# making a second pass necessary.
	print STDERR "\nStarting first BLAST pass for $Fld[0] - $Fld[1] on ";
	system("date");
	# open FHR, "$blastall -C3 -F\"m S\" -i $Fld[0] -d $Fld[1] -p blastp -v $Fld[3] -b $Fld[3] -M $matrix -z 5000000 -m7 | ./$blastParser $score_cutoff|";
	system("$ghostz aln -i $Fld[0] -d $Fld[1] -o tmp.$Fld[0]-$Fld[1] -a $ncpu");
	# die "perl $ghostParser $Fld[0] $Fld[1] tmp.$Fld[0]-$Fld[1] |\n";
	open FHR, "perl $ghostParser $Fld[0] $Fld[1] tmp.$Fld[0]-$Fld[1] |";

	%theHits = ();
	while (<FHR>) {
		$aLine = $_;
		chomp ($aLine);
		@words = split (/\s+/, $aLine);


		if (exists ($theHits {$words [0]})) {
			$theHits {$words [0]} = $theHits {$words [0]}." ".$words [1];
		}
		else {
			$theHits {$words [0]} = $words [1];
		}

	}
	close (FHR);
	# my $num = keys %theHits;
	# die "$num\n";

	$tmpdir = ".";   # May be slightly (5%) faster using the RAM disk "/dev/shm".
	$tmpi = "$tmpdir/tmpi";
	$tmpd = "$tmpdir/tmpd";

	# Do second pass with compositional adjustment off to get full-length alignments.
	print STDERR "\nStarting second BLAST pass for $Fld[0] - $Fld[1] on ";
	system("date");
	unlink "$Fld[4]";
	foreach $aQuery (keys % theHits) {

		# Create single-query file
		open (FHT, ">$tmpi");
		print FHT ">$aQuery\n".$sequencesA {">$aQuery"}."\n";
		close (FHT);

	        # Create mini-database of hit sequences
		open (FHT, ">$tmpd");
		foreach $aHit (split (/\s/, $theHits {$aQuery})) {
			print FHT ">$aHit\n".$sequencesB {">$aHit"}."\n";
		}
		close (FHT);

		# Run Blast and add to output
		# system ("$formatdb -i $tmpd");
		system("$ghostz db -i $tmpd -o $tmpd 1>/dev/null 2>/dev/null");
		# system ("$blastall -C0 -FF -i $tmpi -d $tmpd -p blastp -v $Fld[3] -b $Fld[3] -M $matrix -z 5000000 -m7 | ./$blastParser $score_cutoff >> $Fld[4]");
		# print STDERR "This file $Fld[4] should exists.\n";
		system("$ghostz aln -i $tmpi -d $tmpd -o tmp.i2d -a $ncpu 1>/dev/null 2>/dev/null; perl $ghostParser $tmpi $tmpd tmp.i2d >> $Fld[4]");
	}

	unlink "$tmpi", "$tmpd", "formatdb.log", "$tmpd.phr", "$tmpd.pin", "$tmpd.psq";
}

				 
#   Date                                 Modification
# --------          ---------------------------------------------------
#
# 2006-04-02 [1.36] - Changed score cutoff 50 to 0 for blast2faa.pl.
#                   Reason: after a cluster merger a score can be less than the cutoff (50)
#                   which will remove the sequence in blast2faa.pl.  The bootstrapping will
#                   then fail.
#                   - Fixed bug with index variable in bootstrap routine.
#
# 2006-06-01 [2.0]  - Fixed bug in blast_parser.pl: fields 7 and 8 were swapped,
#                   it was supposed to print match_area before HSP_length.
#                   - Fixed bug in blastall call: -v param was wrong for the A-B
#                   and B-A comparisons.
#                   - 
#                   - Changed "cluster" to "group" consistently in output.
#                   - Changed "main ortholog" to "seed ortholog" in output.
#                   - Replace U -> X before running seqstat.jar, otherwise it crashes.
# 2006-08-04 [2.0]  - In bootstrap subroutine, replace U with X, otherwise seqstat
#                       will crash as this is not in the matrix (should fix this in seqstat)
# 2006-08-04 [2.1]  - Changed to writing default output to file.
#                   - Added options to run blast only.
#                   - Fixed some file closing bugs.
# 2007-12-14 [3.0]  - Sped up sorting routines (by Isabella).
#                   - New XML-based blast_parser.
#                   - New seqstat.jar to handle u and U.
#                   - Modified overlap criterion for rejecting matches.  Now it agrees with the paper.
# 2009-04-01 [4.0]  - Further modification of overlap criteria (require that they are met for both query and subject).
#		    - Changed bit score cutoff to 40, which is suitable for compositionally adjusted BLAST.
#		    - Added in 2-pass algorithm.
# 2009-06-11 [4.0]  - Moved blasting out to subroutine.
#		    - Changed blasting in bootstrap subroutine to use unconditional score matrix adjustment and SEG hard masking,
#		      to be the same as first step of 2-pass blast.
# 2009-06-17 [4.0]  - Compensated a Blast "bug" that sometimes gives a self-match lower score than a non-identical match.
#                      This can happen with score matrix adjustment and can lead to missed orthologs.
# 2009-08-18 [4.0]  - Consolidated Blast filtering parameters for 2-pass (-C3 -F\"m S\"; -C0 -FF)
# 2009-10-09 [4.1]  - Fixed bug that caused failure if Fasta header lines had more than one word.
