#!/bin/perl -w

##Command example:
#./get_superkingdoms.pl flabellina_accnmbr.txt head_nodes.dmp
$names_file="nodes.dmp";

($AccNmbr) = @ARGV;

open($fh, "<", $AccNmbr) || die "Could not open file $AccNmbr/n $!";
my @ids = ();
while (<$fh>) {
    chomp;
    push @ids, $_;
}
print STDERR  "Finished reading taxids \n";

## read in the structure into memory
open($fh2, "<", $names_file) or die "unable to open $names_file $!\n";
while(<$fh2>){
    chomp;
    $_ =~ s/\s+\|\s+/|/g;
    @tmp = split /\|/, $_;
    for $i(0..$#tmp){
        $tmp[$i] =~ s/^\s+//;
        $tmp[$i] =~ s/\s+$//;
        $tax_group{$tmp[0]} = $tmp[2];
        $parent{$tmp[0]} = $tmp[1];
        ## if you want to be able to trace the tree
        ## in the opposite direction then you can also
        ## do
        $daughters{$tmp[1]}{$tmp[0]} = 1;
    }
}
## then if you want to retrace from daughter to the root node ## from C for example:
foreach $id(@ids){
    $node = $id;
    if(!defined($parent{$node})){
        print STDERR "No parent defined for $id\n";
        next;
    }
    while( $tax_group{$node} ne "superkingdom" ){
        $node = $parent{$node};
    }
    print $id, "\t", $node, "\n";
}

## whilst doing something useful with the $node values (eg. sticking them ## in an array).

## to go from the root node and visit all other nodes in the tree you (probably) 
##need to use recursion through the $daughters structure.
## something like:

sub traverse_tree {
    my $node = shift @_;
    ## do something useful with $node
    return if !defined($daughters{$node}) ;
    for my $daughter(keys %{$daughters{$node}} ){
        traverse_tree($daughter);
    }
}
