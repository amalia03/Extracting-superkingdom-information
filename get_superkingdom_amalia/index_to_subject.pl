#!/bin/perl -w
$index_file= "nt_nodes.tsv";
$accnodes= "nt_accid_species.tsv";

#$outfile = "nodes_taxa.tsv";

open($fh, "<", $index_file) || die "Could not open file $index_file $!/n";

while (<$fh>) {
    @tmp = split /\t/, $_;
    $taxon{$tmp[0]} = $tmp[2];
}

#foreach $id (keys %taxon){
#    print "$taxon{$id}\n";
#}
open($fh2, "<", $accnodes) || die "Could not open file $accnodes $!/n";

#open(my $out, '>', $outfile) or die "COuld not open outfile $!/n";

while (<$fh2>) {
    chomp;
   @tmp2 = split /\t/, $_;
    $subj_id = $tmp2[0];
    $taxid= $tmp2[1];
    $NA= 'N/A';
    if(defined($taxon{$taxid})){
        print "$subj_id\t$taxid\t$taxon{$taxid}";
    }else{
        print "$subj_id\t$taxid\t$NA\n";
    }
}

#close $out;

