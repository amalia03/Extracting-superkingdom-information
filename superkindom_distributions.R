#Set working directory
setwd("/home/ama/data/COI_index_seqs/unique_queries_test/coifasta/nt_blast_proks_euks/trinity_vs_nt//")
sk <- read.delim("subject_kingdom.map", header=FALSE, sep="\t", stringsAsFactors=FALSE)
colnames(sk) <- c("subj_id", "accid", "taxgroup")
##Importing the BLAST file
nt_bl <- read.delim("trinity_vs_nt.bl", header=FALSE, sep="\t", stringsAsFactors=FALSE)

##Adding column names
colnames(nt_bl) <- c('query', 'subject', 'title', 'sci.name','com.name', 'taxid', 'qlen',
                     'slen', 'qstart','qend', 'sstart', 'send', 'evalue','score','ali_length',
                     'pident', 'nident','gapopen', 'gaps', 'qcovs')

##Making an column with only the usable part of the subject ID
nt_bl$subj_id <- (sub("\\S+\\|(\\S+)\\|", "\\1", nt_bl$subject, perl=TRUE))

##So that it won't cause any problems during the merge process, create an array consisting of ony the unique columns
sk_uniq <- sk[!duplicated(sk$subj_id),]

##Add the Superkindom information by merging the two datasets together by SubjectID
##Note: after setting all=TRUE, I resolved issues I had with repeating mututal strings
nt_bl_sk <- merge(sk_uniq, nt_bl, by="subj_id", stringsAsFactors=FALSE, all=F)
tail(nt_bl_sk)


##After that I manually fix the table in a tabular format so that I can make a pie chart later
#See below for the customized pie function
taxgroup_frequency(nt_bl_sk, "")

#####
#Now I want to see what ratios of each superkingdom per first group hit..
##First we order and rank them.
nt_sk_ord <- nt_bl_sk[ order( nt_bl_sk$query, -nt_bl_sk$pident, -nt_bl_sk$score, -nt_bl_sk$ali_length, nt_bl_sk$evalue ),]
rank <- tapply(nt_sk_ord[,'score'], nt_sk_ord[,'query'], function(x){ 1:length(x)})
nt_sk_ord <- cbind(nt_sk_ord, 'rank'=unlist(rank), stringsAsFactors=FALSE )
nt_sk_ord <- nt_sk_ord[(nt_sk_ord$rank < 11),]
nt_sk_ord_u <- nt_sk_ord[!duplicated(nt_sk_ord$query),]
nrow(nt_sk_ord_u)
#nt_dum <- nt_sk_ord[(nt_sk_ord$query == "M02443:118:000000000-AMUKU:1:1101:10448:7230"),]

##Then using a customized pie function, I created percentages of each group.
#foreach (unique(nt_sk_ord$taxgroup)) %do%
# group_pie(nt_sk_ord, nt_sk_ord$taxgroup, "I DID IT :D ")
pdf("group_percentages_lower_evalues.pdf", width=7, height=12)
par(mar=c(5,4, 4, 2))
par(mfrow=c(3,1))
taxgroup_frequency(nt_bl_sk, "Overall superkingdom ratios, all results")
taxgroup_frequency(nt_sk_ord, "Overall superkingdom ratios, first ten ranking hits per query")
taxgroup_frequency(nt_sk_ord_u, "Overall superkingdom ratios, only top hits")
group_pie(nt_sk_ord, "Eukaryotes", "Superkingdom ratios when Eukaryotes are top hits ")
group_pie(nt_sk_ord, "Prokaryotes", "Superkingdom ratios when Prokaryotes are tophits")
group_pie(nt_sk_ord, "Viruses", "Superkingdom ratios when Viruses are top hits ")
group_pie(nt_sk_ord, "N/A", "Superkingdom ratios when N/A are top hits")
group_pie(nt_sk_ord, "Archaea", "Superkingdom ratios when Archaea are top hits ")

dev.off()

###
##Functions

##Customized pie function that includes percentages
taxgroup_frequency <- function(x, mt){
  x_freq=as.data.frame(table(x$taxgroup))
  colnames(x_freq) <- c("id","freq")
  numdata <- length(x_freq$freq)
  rainbowcols <- topo.colors(numdata)
  #  freqs <- x_freq$freq
  lbls<- x_freq$id
  pct <- round(x_freq$freq/sum(x_freq$freq)*100)
  lbls <- paste(lbls, pct) # add percents to labels
   #lbls <- paste(lbls,"%\n", freqs, sep="") # ad % to labels
  lbls <- paste(lbls,"%", sep="") # ad % to labels
  pie(x_freq$freq, clockwise=TRUE, border="white", labels = lbls,
      main= paste(mt, "\nTotal Number:", nrow(x)), col = rainbowcols, cex.main=1)
}

##A short function for determining all the rank 1 hits from a stated group group.
rank1 <- function(x, gr){
  x[which(x$rank == 1 & x$taxgroup == gr),]}

##This function picks a stated taxonomic group eg "Eukaryotes", finds all the queries whose rank 1 equals
## that string, removes the first hit and creates a pie chart of the tailing hits.
##Dependant on the rank1 function
##Dependant on taxgroup_freqency function

group_pie <- function(x, gr, mt){
  a <- rank1(x, gr)
  b <- x[x$query %in% a$query, ]
  c <- b[-which(b$rank == 1),]
  taxgroup_frequency(c, mt)
}


### Lets look at score ratios.
### We don't have species information for all of the subject ids in the nt_bl table, so let us
### make subset of it and then use that. (This is not supposed to require more memory, but
### I'm not convinced)

### Amalia, has already made this table using merge... So we can use this with tapply to
### ask some questions..
taxgroups <- unique(nt_bl_sk$taxgroup)

query.tg.ms.l <- tapply(1:nrow(nt_bl_sk), nt_bl_sk$query, function(i){
  sapply(taxgroups, function(tg){
    b <- nt_bl_sk[i, 'taxgroup'] == tg
    ifelse( sum(b), max(nt_bl_sk[i[b], 'score']), 0 )
  })
})
### Amalia, has already made this table using merge... So we can use this with tapply to
### ask some questions..
taxgroups <- unique(nt_bl_sk$taxgroup)

query.tg.ms.l <- tapply(1:nrow(nt_bl_sk), nt_bl_sk$query, function(i){
  sapply(taxgroups, function(tg){
    b <- nt_bl_sk[i, 'taxgroup'] == tg
    ifelse( sum(b), max(nt_bl_sk[i[b], 'score']), 0 )
  })
})

euk.noneuk.r <- sapply( query.tg.ms.l, function(x){ (1 + x['Eukaryotes']) / (1 + max(x[-2])) } )
head(euk.noneuk.r)
sum(is.infinite(euk.noneuk.r)) / length(euk.noneuk.r)
range(euk.noneuk.r[is.finite(euk.noneuk.r)])

hist( log2(euk.noneuk.r))

prok.nonprok.r <- sapply( query.tg.ms.l, function(x){ (1 + x['Prokaryotes']) / (1 +max(x[-3])) } )
hist( log2(prok.nonprok.r))

vir.nonvir.r <- sapply( query.tg.ms.l, function(x){ (1 + x['Viruses']) / (1 + max(x[-4])) } )
hist( log2(vir.nonvir.r))

arc.nonarc.r <- sapply( query.tg.ms.l, function(x){ (1 + x['Archaea']) / (1 + max(x[-5])) } )
hist( log2(arc.nonarc.r))


## this may not be that valid if we are only getting a single species for all the blast alignments
## We can easily check this... by checking the accid which is the taxonomic identifier

query.sp.count <- tapply( 1:nrow(nt_bl_sk), nt_bl_sk$query, function(i){ length(unique(nt_bl_sk[i, 'accid']))})
hist(query.sp.count)
dev.off()
