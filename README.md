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

------
This was not used after it was written even though it works as LMJs script is shorter and does the job in way less steps. 

**/get_superkingdom_amalia/**
Here I deposit my own scripts since they were the initial gruntwork that allowed me to figure out how to establish the workflow but it is a bit more inelegant than it can be. Still easier to see the reasoning behind each step.

**parsing_ids.pl**
Reads in the blast file and retrieves the subjectid from each result.
output file: nt_identifiers.tsv

Then I use:
`sort-u nt_identifiers.tsv > nt_identifiers_uniq.tsv`

To get only unique identifiers from the file. 
Next, I initiated the command: 

**./Acctaxid.pl**

Which reads in the taxidentifiers, the name.dmp and accession taxid files, creates a hash for all defined values seen in the files and 
Used as such: 

`./Acctaxid.pl nt_identifiers_uniq.tsv > nt_accids_species.tsv`

After getting the file above which contains the subj ID, taxID, Species name and Common name, I typed the following command: 

`awk '!a[$2]++' nt_accids_species.tsv > nt_uniq_accids.tsv`

to only get unique taxid values. That is followed by the command to remove empty spaces: 

`awk  '$3!=""' nt_uniq_accids.tsv > nt_accids_uniq_nna.tsv`

Also I remove the common name as it is not the column that is used in this analysis:

`cut -f1,2,3 nt_accids_uniq_nna.tsv > nt_accids_uniq_nna_nc.tsv`

Then I use a script called **remove_broken_strings.pl** whose use is explained better below but for now, it is utilized in such a way that would remove certain "broken" entries that would otherwise initiate an infinite loop during the node traversing stage. 

The command used for this script should be like this: 

`./remove_broken_strings.pl nt_accids_uniq_nna_nc.tsv > nt_accids_clean.tsv`

The ./remove_broken_strings.pl command has one dependable text file called broken_strings.tsv which it us appended every time there is a problematic entry. 



----

So we reach a point now that the file has all the information we need to find the superkingdom for each entry. However there are a few entries whose nodes will lead to an infinite loop. What I did in this case was to find out where the loop was getting stuck by following the steps below: 


./get_superkingdoms.pl nt_accids.tsc > acc_nodes.tsv
