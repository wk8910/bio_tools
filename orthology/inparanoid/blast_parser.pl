#!/usr/bin/perl
use strict; 
use warnings; 
#use lib '/afs/pdc.kth.se/home/k/krifo/vol03/domainAligner/Inparanoid_new/lib64';
#use lib '/afs/pdc.kth.se/home/k/krifo/vol03/domainAligner/Inparanoid_new/lib64/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi';
use XML::Parser; 

##############################################################################################
#
# This parser parses output files from blastall (blastp) and outputs one-line descriptions
# for each hit with a score above or equal to a cut-off score that is specified as a parameter
# to the program. The one-line description contains the following ifomation separated by tab
# * Query id
# * Hit id
# * Bit score
# * Query length
# * Hit length
# * Length of longest segment on query. This is defined as the length of the segment from the
#  	first position od the first hsp to the last position of the last hsp. I.e. if the
# 	hsps are 1-10 and 90-100, the length of the longest segment will be 100.
# * Length of longest segment on hit, see explanation above.
# * Total match length on query. This is defined as the total length of all hsps. If the hsps
# 	are 1-10 and 90-100, the length will be 20.
# * Total match length on hit. see explanation above
# * Positions for all segments on the query and on the hit. Positions on the query is written
# 	as p:1-100 and positions on the hit is writteh as h:1-100. Positions for all hsps are
#	specified separated nt tab. Positions for query and hut for a segment is separated by 
# 	one whitespace. 
# 

# MODIFICATION: also add %identity as next output field
# HOWEVER note this is specifically protein sequence identity of the aligned regions, not all of the proteins

# If alignment mode is used, the parser prints a > before all data on the one-line description.
# The next two lines will contain the aligned sequences, including gaps. Alignment mode is off
# by default but can be used if the second parameter sent to the parser is -a. If alignment
# mode is not used only the score cutoff and the Blast XML file should be sent to the parser.
#
# NB: This parser was created for blast 2.2.16. If you run earlier versions of blast or 
# blast with -VT to emulate the old behaviour the code in this script must be changed a bit.
# The neccesary changes are few and the first change is to un-comment all lines
# marked by ##. Lines marked with ## occurs here at the beginning of the script and on a couple
# of places in the My::TagHandler package (In the Init subroutine). The other change neccessary 
# is to comment/remove all lines marked with #REMOVE THIS LINE FOR OLDER VERSIONS OF BLAST.
#
# Written by Isabella Pekkari 2007-11-19
# Modified by Kristoffer Forslund 2008-05-07 to add biased composition handling
#
##############################################################################################

# First argument is score cutt-of in bits
# Second argument is beta threshold for composition filtering. Set to 0.0 to disable.
# Third argument is blast result file (.xml, i.i run blast with option -m7) that shall be parsed
my $score_cutoff = shift;


# If alignment mode shall be used, the flag -a is specified as the first parameter
# Alignment mode is off by defalut so the flag -a must be specified if this mode shall be used.
my $alignment_mode = 0;
if (defined $ARGV[0] && $ARGV[0] eq '-a') {

	$alignment_mode = 1;
	shift;
} 

# If segments must be ordered in a linear fashion on both sequences.
# If 1, the hsp order must be the same on the query and the hit. 
# For example, if the n-terminal of the hit matches the c-terminal of
# the query another segment where the c-terminal of the hit matches
# the n-terminal of the hit si not allowed.
# If this parameter is set to 0, hsps can be ordered differently on the
# query and the hit. In both cases, an overlap of maximum 5% of the shortest segment
# is allowed.
my $linear_segment_mode = 1;

# Only for older versions of blast
##my $done = 0;



# Create an xml parser
my $p = XML::Parser->new( Style => 'My::TagHandler', ); 

# Create an Expat::NB parser
my $nb_p = $p->parse_start();

# Parse the xml file
parse_document();

sub parse_document {

	while(my $l = <>){ 
	 ##if ($done) {

			##$nb_p->parse_done;
			##$nb_p = $p->parse_start(); 
			##$done = 0;

		##} else {
			# Remove whitespace at the end of the line
			chomp($l); 
##/DEBUG
#	    print STDERR "###" .$l . "###\n";
			# Parse the line
			$nb_p->parse_more($l); 
		##}
	} 
	
	# Shut the parser down
	$nb_p->parse_done;

}

# Only used for older versions of blast
##sub next_doc {

##	$done = 1;

##}



############################################
# Package for parsing xml files obtained
# from blast.
############################################
package My::TagHandler;

use strict;
use warnings;

#Subroutines
my $create_query;
my $store_query_length;
my $new_hit;
my $save_hit_length;
my $new_hsp;
my $save_hsp_start_query;
my $save_hsp_end_query;
my $save_hsp_start_hit;
my $save_hsp_end_hit;
my $save_hsp_qseq;
my $save_hsp_hseq;
my $end_hit;
my $print_query;
my $check_if_overlap_non_linear_allowed;
my $check_if_overlap_linear;

my @current_query;	# The current query
my $current_hit;	# The current hit
my $current_hsp;	# The current hsp

my $currentText = '';	# Text from the current tag

# Names of tags that shall be parsed as key and references to
# the anonymous subroutine that shall be run when parsing the tag as value.
my %tags_to_parse;	

# Reference to the anonymous subroutine that shall be run
# to check whether there is an overlap between two hsps.
my $overlap_sub;

sub Init { 

	my($expat) = @_; 

	#Subroutine for creating new query
	$create_query = sub {

	    # The the query id. Additional information for the query is ignored.
	    my @tmp = split(/\s+/, $currentText);
	    @current_query = ($tmp[0], 0, [])
	};

	#Subroutine for storing query length
	$store_query_length = sub {$current_query[1] = $currentText};

	#Subroutine for creating new hit
	$new_hit = sub {

	    # The the hit id. Additional information for the hit is ignored.
	    my @tmp = split(/\s+/, $currentText);
	    $current_hit = [$tmp[0], 0, 0, 0, 0, [], 0];
	};

	#Subroutine for saving hit length
	$save_hit_length = sub {$current_hit->[1] = $currentText};

	#Subroutine for creating new hsp
	$new_hsp = sub {$current_hsp = [$currentText]};

	# Subroutine for saving hsp start on query
	$save_hsp_start_query = sub {$current_hsp->[1] = $currentText};

	# Subroutine for saving hsp end on query
	$save_hsp_end_query = sub {$current_hsp->[2] = $currentText};

	# Subroutine for saving hsp start on hit
	$save_hsp_start_hit = sub {$current_hsp->[3] = $currentText};

	# Subroutine for saving hsp end on hit
	$save_hsp_end_hit = sub {$current_hsp->[4] = $currentText;};

	# Subroutine for saving hsp query sequence (as in alignment)
	$save_hsp_qseq = sub {$current_hsp->[5] = $currentText;};

	# Subroutine for saving hsp hit sequence (as in alignment)
	$save_hsp_hseq = sub {$current_hsp->[6] = $currentText;

   	    	# Check if this hsp overlaps with any of the
    	    	# existing hsps
		my $overlap_found = 0;
   	    	foreach my $existing_hsp (@{$current_hit->[5]}) {

	    		if ($overlap_sub->($current_hsp, $existing_hsp)) {
				$overlap_found = 1;
				last;
	    		}

   	    	}

    	   	 # If this hsp does not overlap with any hsp it is added


    	    	unless ($overlap_found) {

			# Add the hsp to the hit
			push( @{$current_hit->[5]}, $current_hsp);

			# Increase number of hsps for the hit with one
			$current_hit->[6]++;

			# Add the hsp score to the total score
			$current_hit->[2] += $current_hsp->[0];

			# Add the hsp length on the query to the total hsp length on the query
			$current_hit->[3] += ($current_hsp->[2] - $current_hsp->[1] + 1);

			# Add the hsp length on the hit to the total hsp length on the hit
			$current_hit->[4] += ($current_hsp->[4] - $current_hsp->[3] + 1);
   	    	}

	};

	# Subroutine for saving hit
	$end_hit = sub {
		
	    #Add the hit to the qurrent query
	    unless ($current_hit->[2] < $score_cutoff ) {
	    	push( @{$current_query[2]}, $current_hit );
	    }
	};

	# Subroutine for printing all hits for a query
	$print_query = sub {

		# Sort the hits after score with hit with highest score first
   	   	my @sorted_hits = sort {$b->[2] <=> $a->[2]} @{$current_query[2]};

    	    	# For all hits
    	    	foreach my $hit (@sorted_hits) {

			if ($alignment_mode) {
		
				# When alignment mode is used, self hits are not printed
				# Therefore, the hit is ignored if it has the same id as the query
				next if ($current_query[0] eq $hit->[0]);

				# When alignment mode is used, a > is printed at the start of 
				# lines containing data, i.e. lines that do not contain sequences
				print ">";
			}

			print "$current_query[0]\t"; 	# Print query id
			print "$hit->[0]\t";		# Print hit id
			printf  ("%.1f\t", $hit->[2]);  # Print bit score
			print "$current_query[1]\t";	# Print query length
			print "$hit->[1]\t";		# Print hit length

			if ($hit->[6] > 1) { # if more than one segment

				# Sort hsps on query
    				my @hsps_sorted_on_query = sort {$a->[1] <=> $b->[1]} @{$hit->[5]};
    
    				# Sort hsps on hit
   				my @hsps_sorted_on_hit = sort {$a->[3] <=> $b->[3]} @{$hit->[5]};

    				# Get total segment length on query
    				my $segm_length_query = $hsps_sorted_on_query[@hsps_sorted_on_query - 1]->[2] - $hsps_sorted_on_query[0]->[1] + 1;
    
   		       		# Get total segment length on hit
    				my $segm_length_hit = $hsps_sorted_on_hit[@hsps_sorted_on_hit - 1]->[4] - $hsps_sorted_on_hit[0]->[3] + 1;

				print "$segm_length_query\t";	# Print segment length on query (i.e lengt of the segment started by the first hsp and ended by the last hsp)
				print "$segm_length_hit\t";	# Print segment length on query
				print "$hit->[3]\t$hit->[4]\t";	# Print total length of all hsps on the query and on the match, i.e length of actually matching region

				# In alignment mode, the aligned sequences shall be printed on the lines following the data line
				my $hsp_qseq = '';
				my $hsp_hseq = '';

    				# Print query and hit segment positions
    				foreach my $segment (@hsps_sorted_on_query) {

					print "q:$segment->[1]-$segment->[2] ";
					print "h:$segment->[3]-$segment->[4]\t";

					if ($alignment_mode) {
						
						# Add the hsp sequences to the total sequence
						$hsp_qseq .= $segment->[5];
						$hsp_hseq .= $segment->[6];
					}

    				}

   				print "\n";

				if ($alignment_mode) {
			
					# Print sequences
					print "$hsp_qseq\n";
					print "$hsp_hseq\n";
				}

			} else {
				# Get the only hsp that was found for this hit
				my $segment = $hit->[5]->[0];

				# Get total segment length on query
    				my $segm_length_query = $segment->[2] - $segment->[1] + 1;
    
   		       		# Get total segment length on hit
    				my $segm_length_hit = $segment->[4] - $segment->[3] + 1;

				print "$segm_length_query\t"; 	# Print segment length on query, i.e. length of this hsp on query
				print "$segm_length_hit\t";	# Print segment length on hit, i.e. length of this hsp on hit

				# Print total length of all hsps on the query and on the match, i.e length of actually matching region
				# Sice there is only one segment, these lengths will be the same as the segment lengths printed above.
				print "$hit->[3]\t$hit->[4]\t"; 

				# Print segment positions

				print "q:$segment->[1]-$segment->[2] ";
				print "h:$segment->[3]-$segment->[4]\t";
				print "\n";

				if ($alignment_mode) {
			
					# Print sequences
					print "$segment->[5]\n";
					print "$segment->[6]\n";
				}

			}
   	    	}
	    	##main::next_doc(); #NB! Un-comment for older blast versions 

	};

	# Subroutine for checking if two hsps overlap.
	# When this subroutine is used, non-linear arrangements of the hsps are allowed.
	$check_if_overlap_non_linear_allowed = sub {

    		my $hsp1  = shift;	# One hsp
   		my $hsp2 = shift;	# Another hsp 

		# Check if there is an overlap.
    		return (_check_overlap_non_linear_allowed($hsp1->[1], $hsp1->[2], $hsp2->[1], $hsp2->[2]) 
			|| _check_overlap_non_linear_allowed($hsp1->[3], $hsp1->[4], $hsp2->[3], $hsp2->[4]));

	};

	# Subroutine for checking if two hsps overlap.
	# When this subroutine is used, non-linear arrangements of the hsps are not allowed.
	$check_if_overlap_linear = sub {

    		my $hsp1  = shift;	# One hsp
   		my $hsp2 = shift;	# Another hsp 

    		# Get start point for hsp1 on query
   		my $start1_hsp1 = $hsp1->[1];

    		# Get start point for hsp2 on query
    		my $start1_hsp2 = $hsp2->[1];

    		# The hsp that comes first oon the query (N-terminal hsp)
    		my $first_hsp;

    		# The hsp that comes last on the query
    		my $last_hsp;

    		# Check which hsp is N-teminal.
    		if ($start1_hsp1 eq $start1_hsp2) { # If the fragments start at the same position, there is an overlap (100% of shorter sequence)
			return 1;
    		} elsif ($start1_hsp1 < $start1_hsp2) { 

			$first_hsp = $hsp1;
			$last_hsp = $hsp2;

   		} else {
	
			$first_hsp = $hsp2;
			$last_hsp = $hsp1;

    		}
		
   		# Return whether there is an overlap or not.
		return (_check_overlap_linear($first_hsp->[1], $first_hsp->[2], $last_hsp->[1], $last_hsp->[2]) 
			|| _check_overlap_linear($first_hsp->[3], $first_hsp->[4], $last_hsp->[3], $last_hsp->[4]));
	};

	%tags_to_parse = (

	         ##'BlastOutput_query-def' => $create_query, 
		 ##'BlastOutput_query-def' => $create_query,		
##	         'BlastOutput_query-def' => $create_query, 
##		 'BlastOutput_query-len' => $store_query_length,		
		 'Iteration_query-def' => $create_query,		# Query id		#REMOVE THIS LINE FOR OLDER VERSIONS OF BLAST
		 'Iteration_query-len' => $store_query_length, 		# Query length		#REMOVE THIS LINE FOR OLDER VERSIONS OF BLAST
		 'Hit_def' => $new_hit,               			# Hit id
		 'Hit_len' => $save_hit_length,              		# Hit length
		 'Hsp_bit-score' => $new_hsp,         			# Hsp bit score
		 'Hsp_query-from' => $save_hsp_start_query,        	# Start point for hsp on query
		 'Hsp_query-to' => $save_hsp_end_query,         	# End point for hsp on query
		 'Hsp_hit-from' => $save_hsp_start_hit,          	# Start position for hsp on hit
		 'Hsp_hit-to' => $save_hsp_end_hit,            		# End position for hsp on hit
		 'Hsp_qseq' => $save_hsp_qseq,				# Hsp query sequence (gapped as in the alignment)	
		 'Hsp_hseq' => $save_hsp_hseq,				# Hsp hit sequence (gapped as in the alignment)		
		 'Hit_hsps' => $end_hit,				# End of hit
		 ##'BlastOutput' => $print_query
		 'Iteration' => $print_query				# End of query		#REMOVE THIS LINE FOR OLDER VERSIONS OF BLAST	
	);

	# Set overlap subroutine to use
	if ($linear_segment_mode eq 1) {
		$overlap_sub = $check_if_overlap_linear;
	} else {
		$overlap_sub = $check_if_overlap_non_linear_allowed;
	}
} 

# Nothing is done when encountering a start tag
#sub Start
#{

#}

sub End {

	my($expat, $tag) = @_; 

	# If the name of the tag is in the table with names of tags to parse,
	# run the corresponding subroutine
	$tags_to_parse{$tag} && do { $tags_to_parse{$tag}->()};

}

sub Char
{
	my($expat, $text) = @_;
	# Save the tag text
	$currentText = $text;
}

sub _check_overlap_linear {

    my ($start1, $end1, $start2, $end2) = @_;

    # Length of segment 1
    my $length1 = $end1 - $start1 + 1;

    # Length of segment 2
    my $length2 = $end2 - $start2 + 1;

    # Get the length of the sortest of these segments
    my $shortest_length = ($length1 < $length2)?$length1:$length2;

    # Maxumin of 5% overlap (witg regard to the shorter segment) is allowed
    return (($start2 - $end1 - 1) / $shortest_length < - 0.05);  
}



sub _check_overlap_non_linear_allowed {

    my ($start1, $end1, $start2, $end2) = @_;

    # Length of segment 1
    my $length1 = $end1 - $start1 + 1;

    # Length of segment 2
    my $length2 = $end2 - $start2 + 1;

    # Get the length of the sortest of these segments
    my $shortest_length = ($length1 < $length2)?$length1:$length2;

    if ($start1 eq $start2) { # If the fragment start at the same position, there is an overlap (100% of shorter sequence)
	return 1;
    } elsif ($start1 < $start2) { 

	if (($start2 - $end1 + 1) / $shortest_length < - 0.05) {
		return 1;
	}

    } else {
	
	if (($start1 - $end2 + 1) / $shortest_length < - 0.05) {
		return 1;
	}

    }

    # If the method has not returned yet, there is no overlap
    return 0;
}
