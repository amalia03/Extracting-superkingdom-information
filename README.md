# Extracting-superkingdom-information
Contains my own long-donkey script thread and MLJs one -in-all script that groups the fasta sequences by tracing back their superkingdom information . 
Other than the scripts what is required are the following:

The NCBI taxonomy database information downloaded from this link:
wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/

and then extracting the files by using the command:
gunzip -c taxdump.tar.gz | tar xf 

Also the scripts takes in a BLAST output whose format should be like :
'6 qseqid sseqid stitle ssciname scomname staxid qlen slen qstart qend
 sstart send evalue score length pident nident gapopen gaps qcovs' -num_threads 25
 -max_target_seqs 10
 
**/get_superkingdom_amalia/**
Here I deposit my own scripts since they were the initial gruntwork that allowed me to figure out how to establish the workflow but it is a bit more inelegant than it can be. Still easier to see the reasoning behind each step.

**parsing_ids.pl**
Reads in the blast file and retrieves the subjectid from each result.
output file: nt_identifiers.tsv

Then I use 
`sort-u nt_identifiers.tsv > nt_identifiers_uniq.tsv`

To get only unique identifiers from the file. 
Next, I initiated the command: 
**./Acctaxid.pl**
Which reads in the taxidentifiers, the name.dmp and accession taxid files, creates a hash for all defined values seen in the files and 
Used as such: 
`./Acctaxid.pl nt_identifiers_uniq.tsv > nt_accids_species.tsv`

After getting the file above which contains the subj ID, taxID, Species name and Common name, I type the following command: 
`awk '!a[$2]++' nt_accids_species.tsv > nt_uniq_accids.tsv`

to only get unique taxid values. That is followed by the command: 
`awk  '$3!=""' nt_uniq_accids.tsv > nt_accids_uniq_nna.tsv`

To remove the emppty spaces

Also I remove the common name as it is not the column that is used in this analysis
`cut -f1,2,3 nt_accids_uniq_nna.tsv > nt_accids_uniq_nna_nc.tsv`


cut -f1,2,3 nt_accids_uniq_nna.tsv > nt_accids_uniq_nna_nc.tsv


