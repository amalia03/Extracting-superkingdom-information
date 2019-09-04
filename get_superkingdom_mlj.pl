#!/bin/perl -w
##
## This script will find all unique subject ids in the blast file
## and map these to taxonomy identifers.
## For each unique taxonomy identifer it will then go up the
## tree (defined in nodes_file) and find which superkingdom
## the identifeir belongs.
## It will output two files:
## 1. mapping subject id => tax_id
## 2. mapping tax_id => superkingdom.
##
## subject_id => tax_id will be written to "subject_taxid.map"
## subject_id => superkingdom will be written to "subject_kingdom.map"

## note that not all tax_ids map to a superkingdom
## (environmental samples etc.) and we have to deal with
## this somehow.

### WARNING:
##  This script assumes that the blast file contains subject ids
##  in the second column, and that these looks like aaaa|acid|...
##

($blast_file) = @ARGV;
$acc_tax_file = "/home/ama/data/taxonomy/nucl_gb.accession2taxid";
$nodes_file = "/home/ama/data/taxonomy/nodes.dmp";

## read the taxonomy tree in first...
open(IN, $nodes_file) or die "unable to open $nodes_file $!\n";
while(<IN>){
    chomp;
##    $_ =~ s/\s+\|\s+/|/g;
    $_ =~ s/\s//g;
    @tmp = split /\|/, $_;
    ## we probably don't need to do the following..
    ## as there should not be any leading spaces.
    # for($i=0; $i < 3 && $i < @tmp; $i++){
    #     $tmp[$i] =~ s/^\s+//;
    #     $tmp[$i] =~ s/\s+$//;
    # }
    $tax_group{$tmp[0]} = $tmp[2];
    $parent{$tmp[0]} = $tmp[1];
    ## if you want to be able to trace the tree
    ## in the opposite direction then you can also
    ## do
    ## $daughters{$tmp[1]}{$tmp[0]} = 1;
}

print STDERR "finished reading the taxonomy tree\n";


## secondly parse the blast file to get unique identifiers
open(IN, $blast_file) || die "unable to open $blast_file $!\n";
while(<IN>){
    @tmp = split /\t/, $_;
    if($tmp[1] =~ /^[^\|]+\|([^\|]+)/){
        $subjects{$1} = $tmp[1];
    }else{
        $subjects{$tmp[1]} = $tmp[1];
         }
}

print STDERR "Finished parsing the blast file $!\n";

@subjects = sort keys %subjects;

## Then we have the thing that takes a long time.. we expect.
##
open(OUT, ">", "subject_taxid.map") || die "unable to open subject_taxid.map for \
writing $!\n";
open(IN, $acc_tax_file) || die "unable to open $acc_tax_file $!\n";
chomp($header = <IN>);
$header = $header; ## avoid warnings.
while(<IN>){
    @tmp = split;
    ## this looks up a hash every time.
    if( defined($subjects{$tmp[1]}) ){
        $sub_tax{$tmp[1]} = $tmp[2];
        print OUT "$tmp[1]\t$tmp[2]\t$subjects{$tmp[1]}\n";
         }
}
close(OUT);

print STDERR "finished reading the accession id to taxonomy id file\n";

## now we have to read in the taxonomy tree, and then we
## can go through all of our identifers...


## go through each of our subject id / tax id combinations and go
## up the tree to find the superkingdom.
open(OUT, ">subject_kingdom.map") || die "Unable to open subject_kingdom.map $!\n\
";
foreach $id(@subjects){
    if( !defined( $sub_tax{$id}) ){
        print OUT $id, "\t", $subjects{$id}, "\tNULL\tNULL\n";
        next;
    }
      }
    $node = $sub_tax{$id};
    if(!defined($parent{$node})){
        print STDERR "No parent defined for $id\n";
        print OUT $id, "\t", $subjects{$id}, "\t", $sub_tax{$id}, "\tNULL\n";
        next;
    }
    while( $tax_group{$node} ne "superkingdom" && $node != $parent{$node} ){
        $node = $parent{$node};
    }
    print OUT $id, "\t", $subjects{$id}, "\t", $sub_tax{$id}, "\t", $node, "\n";
}
