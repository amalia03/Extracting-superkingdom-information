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
