
#!/bin/perl -w

($blast) = @ARGV;

my $outfile = "nt_identifiers.tsv";

open($in, "<", $blast) || die "Could not open file $blast $!/n";

open(my $out, '>', $outfile) or die "Could not open file '$filename' $!";

while (<$in>) {
    @tmp = split /\t/, $_;
    $id = $tmp[1];
    if ($id =~ /\S+\|\S+/){
        @subj = split('\|', $id);

        print $out "$subj[1]\n";
    }else{
        print $out "$id\n";
    }
}
close $out;
