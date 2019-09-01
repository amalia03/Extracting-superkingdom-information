#!/usr/bin/perl -w
#For the purposes in nt_blast_proks_euks, the command is
##./Acctaxid.pl nt_identifiers /home/ama/data/taxonomy/names.dmp /home/ama/data/t\
axonomy/nucl_gb.accession2taxid > nt_accids.tsv
#($AccNmbr, $names_file, $TaxAccId) = @ARGV;
$names_file="/home/ama/data/taxonomy/names.dmp";
$TaxAccId= "/home/ama/data/taxonomy/nucl_gb.accession2taxid";

($AccNmbr) = @ARGV;

open($fh, "<", $AccNmbr) || die "Could not open file $AccNmbr/n $!";
##I define each part on the list as part of an array
my @ids = ();
while (<$fh>) {
    chomp;
    $ac_id{$_} = 1;
    push @ids, $_;
}
print STDERR  "Finished reading ids \n";

open($fh, "<", $names_file) or die "unable to open $names_file $!\n";
while(<$fh>){
  chomp;
  $_ =~ s/\s+\|\s+/|/g;
  @tmp = split /\|/, $_;
  for $i(0..$#tmp){
      $tmp[$i] =~ s/^\s+//;
      $tmp[$i] =~ s/\s+$//;
  }
  if($tmp[3] eq "scientific name" || $tmp[3] eq "common name"){
      $names{$tmp[0]}{$tmp[3]} = $tmp[1];
  }
}
print STDERR "Finished reading in the names\n";
open($fh2, "<", $TaxAccId) || die "Could not open file $TaxAccId $!/n";
while(<$fh2>){
    chomp;
    ($ac, $ac_v, $taxid, $gi) = split /\s+/, $_;
    if(defined($ac_id{$ac_v})){
      $ac_taxid{$ac_v} = $taxid;
#      print ".";
    }
}
#print ":\n";

for $id(@ids){
  ## we want to print out:
  ## accession id
  ## taxonomy id (if we have found one)
  ## scientific name (if we have one)
  ## common name (if we have one)
  print $id;
  print_value($id, \%ac_taxid);
  if(defined($ac_taxid{$id})){
    if(defined($names{$ac_taxid{$id}})){
     if(defined($names{$ac_taxid{$id}})){
      print_value("scientific name", $names{$ac_taxid{$id}});
      print_value("common name", $names{$ac_taxid{$id}});
    }
  }else{
    print "\tNA\tNA";
  }
  print "\n";
}

sub print_value {
  my($key, $hash_ref ) = @_;
  print "\t";
  if(defined($hash_ref->{$key})){
      print $hash_ref->{$key};
  }else{
    print "NA";
  }
}

