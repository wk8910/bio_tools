#!/usr/bin/perl
use strict;
use warnings;

# gbf2tbl.pl


#  NCBI is supplying this Perl script for the convenience of GenBank
#  submitters who record their genome annotation in a format similar to
#  GenBank or EMBL reports. The gbf2tbl.pl parser allows some variation from
#  the official strict flat file conventions. Additional idiosyncrasies in
#  format can be supported by modification of the script. Any suggestions for
#  improvements or corrections are welcome. However, given the number of
#  possible variations of local data files and conditions, NCBI cannot
#  promise to implement them all and cannot be expected to troubleshoot local
#  installations. This script is being supplied as is, but you are always
#  welcome to make any changes or improvements yourself.
#
#  The script produces annotated FASTA and 5-column feature table files,
#  which are then read by tbl2asn to complete the submission preparation
#  process. Submitters are expected to provide data that meet the annotation
#  criteria for acceptance by GenBank. This includes annotating coding
#  regions and structural RNAs, providing a gene feature with a unique
#  /locus_tag qualifier for each, and confirming that all CDS features
#  translate into proteins without error.
#
#  For convenience, tbl2asn also runs the NCBI sequence record validator,
#  which checks the resulting record for many kinds of errors and
#  inconsistencies. Even syntactically correct records will be rejected if
#  they do not contain information required by GenBank policy. Examining the
#  validator output from tbl2asn and correcting the underlying data is
#  critical to ensure that submissions are acceptable.
#
#  Existing examples from several annotation pipeline outputs have been used
#  to build the parser and have it accommodate information as presented.
#  Additional conversions are described below:
#
#  If the ACCESSION is blank or "unknown", the sequence identifier is taken
#  from the LOCUS line.
#
#  If the source feature is missing, the taxonomic name is taken from the
#  ORGANISM line.
#
#  Feature keys or qualifiers that are not present in the INSDC feature table
#  document are reported in a .err file, and are not added to the 5-column
#  feature table. See http://www.insdc.org/documents/feature_table.html for
#  details.
#
#  A few non-standard qualifiers are allowed and are converted to the
#  appropriate field in the output file. These include codon_recognized,
#  go_component, and region_name.
#
#  Feature intervals that refer to 'far' locations, i.e., those not within
#  the cited record and which have an accession and colon, are suppressed.
#  Those rare features (e.g., trans-splicing between molecules) must be
#  annotated later using Sequin.
#
#  The genetic code in the FASTA definition line, necessary for proper
#  translation of protein coding regions, is taken from a CDS /transl_table
#  qualifier.
#
#  A companion script, tblfix.pl, can perform various data conversions on the
#  resulting feature table files, with the conversion function specified by a
#  command line argument.


# Script to convert pseudo-GenBank or pseudo-EMBL files to FASTA and
# 5-column feature table files suitable for submission to NCBI using
# the tbl2asn or Sequin programs.

my $gbffile = shift or die "Must supply input filename\n";
open (my $GBF_IN, $gbffile) or die "Unable to open $gbffile\n";

my $base = $gbffile;
if ($base =~ /^(.+)\.gbf$/ || $base =~ /^(.+)\.gbk$/ || $base =~ /^(.+)\.gb$/ ||
    $base =~ /^(.+)\.embl$/ || $base =~ /^(.+)\.emb$/ || $base =~ /^(.+)\.eb$/ ||
    $base =~ /^(.+)\.art$/) {
  $base = $1;
}
open (my $FSA_OUT, ">$base.fsa") or die "Unable to open sequence output file\n";
open (my $TBL_OUT, ">$base.tbl") or die "Unable to open feature table output file\n";
open (my $ERR_OUT, ">$base.err") or die "Unable to open error output file\n";

# define global variables

my $has_errors = 0;
my $line_number = 0;

# state variables for tracking current position in flatfile

my $in_seq;
my $in_feat;
my $in_key;
my $in_qual;
my $current_key;
my $current_loc;
my $current_qual;
my $current_val;
my $organism;
my $topology;
my $is_source;
my $is_translation;
my $transl_table;
my $thisline;
my $curr_seq;
my $locus;
my $accn;
my $is_order;
my $organism_ok;
my $printed_heading;

# subroutine to clear state variables for each flatfile
# start in in_feat state to gracefully handle missing FEATURES/FH line

sub clearflags {
  $in_seq = 0;
  $in_feat = 1;
  $in_key = 0;
  $in_qual = 0;
  $current_key = "";
  $current_loc = "";
  $current_qual = "";
  $current_val = "";
  $organism = "";
  $topology = "";
  $is_source = 0;
  $is_translation = 0;
  $transl_table = 1;
  $thisline = "";
  $curr_seq = "";
  $locus = "";
  $accn = "";
  $is_order = 0;
  $organism_ok = 0;
  $printed_heading = 0;
}

# hashes for confirming legal feature keys and legal qualifier names

my %legal_keys = ();
my %legal_quals = ();

sub createlists {
  my @keys = qw/3clip 3UTR 5clip 5UTR 10_signal35_signal
  allele attenuator C_region CAAT_signal CDS centromere
  conflict D_loop D_segment enhancer exon gap GC_signal
  gene iDNA intron J_segment LTR mat_peptide misc_binding
  misc_difference misc_feature misc_recomb misc_RNA
  misc_signal misc_structure mobile_element modified_base
  mRNA mutation N_region ncRNA old_sequence operon oriT
  polyA_signal polyA_site precursor_RNA preprotein preRNA
  prim_transcript primer_bind promoter protein_bind RBS
  rep_origin repeat_region repeat_unit rRNA S_region
  satellite scRNA sig_peptide site_ref snoRNA snRNA
  source stem_loop STS TATA_signal telomere terminator
  tmRNA transit_peptide tRNA unsure V_region V_segment
  variation virion/;

  foreach my $thiskey (@keys) {
    $legal_keys{lc($thiskey)} = 1;
  }

  my @quals = qw/allele anticodon artificial_location
  bio_material bound_moiety cell_line cell_type
  chloroplast chromoplast chromosome citation clone_lib
  clone codon_start codon collected_by collection_date
  compare cons_splice country cultivar culture_collection
  cyanelle db_xref dev_stage direction EC_number ecotype
  environmental_sample estimated_length evidence
  exception experiment focus frequency function gap_type
  gdb_xref gene_synonym gene germline haplogroup haplotype
  identified_by inference insertion_seq isolate
  isolation_source kinetoplast lab_host label lat_lon
  linkage_evidence locus_tag macronuclear map mating_type
  metagenomic mitochondrion mobile_element_type
  mobile_element mod_base mol_type ncRNA_class note
  number old_locus_tag operon organelle organism partial
  PCR_conditions PCR_primers phenotype plasmid
  pop_variant product protein_id proviral pseudo
  pseudogene rearranged replace ribosomal_slippage
  rpt_family rpt_type rpt_unit_range rpt_unit_seq
  rpt_unit satellite segment sequenced_mol serotype
  serovar sex specific_host specimen_voucher
  standard_name strain sub_clone sub_species sub_strain
  tag_peptide tissue_lib tissue_type trans_splicing
  transcript_id transgenic transl_except transl_table
  translation transposon UniProtKB_evidence usedin
  variety virion go_component go_function go_process
  codon_recognized bond_type gene_desc gene_syn prot_desc
  prot_note region_name site_type/;

  foreach my $thisqual (@quals) {
    $legal_quals{lc($thisqual)} = 1;
  }
}

# recursive subroutine for parsing flatfile representation of feature location

sub parseloc {
  my $subloc = shift (@_);
  my @working = ();

  if ($subloc =~ /^join\((.+)\)$/) {
    my $temploc = $1;
    my @items = split (',', $temploc);
    foreach my $thisloc (@items) {
      if ($thisloc !~ /^.*:.*$/) {
        push (@working, parseloc ($thisloc));
      }
    }

  } elsif ($subloc =~ /^order\((.+)\)$/) {
    $is_order = 1;
    my $temploc = $1;
    my @items = split (',', $temploc);
    foreach my $thisloc (@items) {
      if ($thisloc !~ /^.*:.*$/) {
        push (@working, parseloc ($thisloc));
      }
    }

  } elsif ($subloc =~ /^complement\((.+)\)$/) {
    my $comploc = $1;
    my @items = parseloc ($comploc);
    my @rev = reverse (@items);
    foreach my $thisloc (@rev) {
      if ($thisloc =~ /^([^.]+)\.\.([^.]+)$/) {
        $thisloc = "$2..$1";
      }

      if ($thisloc =~ /^>([^.]+)\.\.([^.]+)$/) {
        $thisloc = "<$1..$2";
      }
      if ($thisloc =~ /^([^.]+)\.\.<([^.]+)$/) {
        $thisloc = "$1..>$2";
      }

      if ($thisloc !~ /^.*:.*$/) {
        push (@working, parseloc ($thisloc));
      }
    }

  } elsif ($subloc !~ /^.*:.*$/) {
    push (@working, $subloc);
  }

  return @working;
}

#subroutine to print next feature key / location / qualifier line

sub flushline {
  if ($printed_heading == 0) {
    if ($accn eq "" || $accn =~ /^unknown.*/) {
      $accn = $locus;
    }
    # report identifier
    print $FSA_OUT ">$accn";
    print $TBL_OUT ">Feature $accn\n";
    $printed_heading = 1;
  }

  if ($in_key == 1) {

    if (! $legal_keys{lc($current_key)}) {
      print $ERR_OUT "Bad feature\tLine $line_number\t$current_key\n";
      $has_errors = 1;

    } elsif ($is_source == 0) {

      # parse join() order() complement() ###..### location
      $is_order = 0;
      my @theloc = parseloc ($current_loc);
      # convert number (dot) (dot) number to number (tab) number
      foreach my $thisloc (@theloc) {
        if ($thisloc =~ /^([^.]+)\.\.([^.]+)$/) {
          $thisloc = "$1\t$2";
        } elsif ($thisloc =~ /^(.+)\^(.+)$/) {
          $thisloc = "$1\^\t$2";
        } elsif ($thisloc =~ /^([^.]+)$/) {
          $thisloc = "$1\t$1";
        }
      }
      #print feature key and intervals
      my $first = shift (@theloc);
      print $TBL_OUT "$first\t$current_key\n";
      foreach my $thisloc (@theloc) {
        print $TBL_OUT "$thisloc\n";
      }
      if ($is_order == 1) {
        # generate order qualifier to force use of order instead of join
        print $TBL_OUT "\t\t\torder\n";
      }
    }

  } elsif ($in_qual == 1) {

    if (! $legal_quals{lc($current_qual)}) {
      print $ERR_OUT "Bad qualifier\tLine $line_number\t$current_qual\n";
      $has_errors = 1;

    } elsif (! $legal_keys{lc($current_key)}) {
      $has_errors = 1;

    } elsif ($is_source == 1) {
      if ($current_val eq "") {
        print $FSA_OUT " [$current_qual=]";
      } else {
        print $FSA_OUT " [$current_qual=$current_val]";
        if ($current_qual eq "organism") {
          $organism = "";
          $organism_ok = 1;
        }
      }

    } elsif ($current_qual ne "translation") {
      if ($current_val eq "") {
        print $TBL_OUT "\t\t\t$current_qual\n";
      } else {
        print $TBL_OUT "\t\t\t$current_qual\t$current_val\n";
      }
    }
  }
}

# initialize flags and lists at start of program

clearflags ();

createlists ();

# main loop reads one line at a time

while ($thisline = <$GBF_IN>) {
  $thisline =~ s/\r//;
  $thisline =~ s/\n//;
  $line_number++;

  if ($thisline =~ /^LOCUS\s+(\S*).*$/ ||
      $thisline =~ /^ID\s+(\S*);.*$/ || $thisline =~ /^ID\s+(\S*)\s+SV\s+\d+;.*$/) {
    # record locus
    $locus = $1;
    if ($thisline =~ /^.*(linear).*$/ || $thisline =~ /^.*(circular).*$/) {
      $topology = $1;
    }

  } elsif ($thisline =~ /^ACCESSION\s*(\S*).*$/ || $thisline =~ /^AC\s*(.*);.*$/) {
    # record accession
    $accn = $1;

  } elsif ($thisline =~ /^ {1,3}ORGANISM\s+(.*)$/ || $thisline =~ /^OS\s+(.*)$/) {
    # record organism
    $organism = $1;
    if ($organism =~ /^([^(]*) \(.*\)/) {
      $organism = $1;
    }

  } elsif ($thisline =~ /^FEATURES\s+.*$/ || $thisline =~ /^FH\s+.*$/) {
    # beginning of feature table, flags already set up

  } elsif ($thisline =~ /^ORIGIN\s*.*$/ || $thisline =~ /^SQ\s*.*$/) {
    # end of feature table, print final newline
    flushline ();
    if ($in_seq == 0) {
      if ($organism ne "") {
        print $FSA_OUT " [organism=$organism]";
        $organism_ok = 1;
      }
      if ($topology ne "") {
        print $FSA_OUT " [topology=$topology]";
      }
      if ($transl_table > 1) {
        print $FSA_OUT " [gcode=$transl_table]";
      }
      print $FSA_OUT "\n";
    }
    $in_feat = 0;
    $in_key = 0;
    $in_qual = 0;
    $is_source = 0;
    $is_translation = 0;
    $in_seq = 1;

  } elsif ($thisline =~ /^\/\/\.*/) {
    if ($organism_ok == 0) {
      print $ERR_OUT "ERROR - No organism found\n";
    }
    # at end-of-record double slash, reset variables for catenated flatfiles
    clearflags ();

  } elsif ($in_seq == 1) {

    if ($thisline =~ /^\s+\d+ (.*)$/ || $thisline =~ /^\s+(.*)\s+\d+$/) {
      # report sequence
      $curr_seq = $1;
      $curr_seq =~ s/ //g;
      $curr_seq = uc $curr_seq;
      print $FSA_OUT "$curr_seq\n";
    }

  } elsif ($in_feat == 1) {

    if ($thisline =~ /^ {1,10}(\w+)\s+(.*)$/ || $thisline =~ /^FT   (\w+)\s+(.*)$/) {
      # new feature key and location
      flushline ();
      $in_key = 1;
      $in_qual = 0;
      $current_key = $1;
      $current_loc = $2;
      if ($current_key =~ /source/ || $current_key =~ /Source/) {
        $is_source = 1;
      } else {
        $is_source = 0;
      }

    } elsif ($thisline =~ /^\s+\/(\w+)=(.*)$/ || $thisline =~ /^FT\s+\/(\w+)=(.*)$/) {
      # new qualifier
      flushline ();
      $in_key = 0;
      $in_qual = 1;
      $current_qual = $1;
      # remove leading double quote
      my $val = $2;
      $val =~ s/\"//g;
      $current_val = $val;
      if ($current_qual =~ /translation/) {
        $is_translation = 1;
      } else {
        $is_translation = 0;
      }
      if ($current_qual =~ /transl_table/) {
        $transl_table = $current_val;
      }

    } elsif ($thisline =~ /^\s+\/(\w+)$/ || $thisline =~ /^FT\s+\/(\w+)$/) {
      # new singleton qualifier - e.g., trans-splicing, pseudo
      flushline ();
      $in_key = 0;
      $in_qual = 1;
      $current_qual = $1;
      $current_val = "";
      $is_translation = 0;

    } elsif ($thisline =~ /^\s+(.*)$/ || $thisline =~ /^FT\s+(.*)$/) {

      if ($in_key == 1) {
        # continuation of feature location
        $current_loc = $current_loc . $1;

      } elsif ($in_qual == 1) {
        # continuation of qualifier
        # remove trailing double quote
        my $val = $1;
        $val =~ s/\"//g;
        if ($is_translation == 1) {
          $current_val = $current_val . $val;
        } else {
          $current_val = $current_val . " " . $val;
        }
      }
    }
  }
}

# close input and output files

close ($GBF_IN);
close ($FSA_OUT);
close ($TBL_OUT);
close ($ERR_OUT);

# if no bad features or qualifiers, remove error file

if (! $has_errors) {
  unlink ("$base.err");
}

