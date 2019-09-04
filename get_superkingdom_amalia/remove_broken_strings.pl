#!/bin/perl -w

my $br_str = "broken_node_strings.txt";
my ($dataset ) = @ARGV;
open(my $fh, "<", $br_str ) || die "Could not open file $br_str/n $!";

my %strings;
while (<$fh>) {
    chomp;
    $strings{$_}++;
}

open(my $fh2, "<", $dataset ) || die "Could not open file $dataset $!/n";
while (<$fh2>) {
    chomp;
    my @tmp = split /\s+/, $_;
#since the key I want to remove may exist in various positions in the string, usually at the start and the end, 
#eg_ Tetrahymena transformation vector, synthetic bacteria, I decided to complicate the initial removal command 
#by adding the -1 and -2 options (if the latter reaches the taxid, it still should nt be affected).

    my $groups = $tmp[2];
    my $groups_end = $tmp[-1];
    my $groups_end2 = $tmp[-2];
    print "$_\n" unless exists $strings{$groups} | exists $strings{$groups_end} |
exists $strings{$groups_end2};
}

