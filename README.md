# hts_scripts
A collection of scripts for the analysis of high throuput sequencing data

SummarizeTables.pl combines several table like text files in a single table by comparing the identifier columns.
usage: SummarizeTables.pl [-cut patterns] [-header/noheader] [-comment <comment pattern, default: non>] [-skip <number of lines to skip, default:0>] [-idx <idx of id column(s), default:0>] [-val <idx of value columns, default:all>] [-sep <input delimiter>] [-del <output delimiter>] [-na <NA-value, default=NA>] <file1> <file2> ...

summarize_bs_in_bins.pl summarizes bisulfite values in genome-wide bins of fixed size by computing the average (for % methylation values) or summing (for bs-seq counts) all values within a window. 
usage: summarize_bs_in_bins.pl [-binsz <binsize>] [-mean] [-pos <, sep index of chr, pos>] [-ignore <, sep index of columns to ignore>] <bs filename>
