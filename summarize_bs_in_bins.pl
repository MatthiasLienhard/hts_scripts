#!/usr/bin/perl -w


use strict;
use Getopt::Long;
use File::Basename;

my @l;
my %sum;
my %number;
my $posopt;
my $ignopt;
my @values;
my @pos=(0,1);
my @ignore=();
my $binsz=250;
my $mean=0;

GetOptions ("pos=s" => \$posopt,"ignore=s" => \$ignopt,"binsz=i" => \$binsz , "mean!" => \$mean);

if (defined $posopt){
  @pos=split(",",$posopt);
}
if (defined $ignopt){
  @ignore=split(",",$ignopt);
}


if($#ARGV != 0) {
	die "$0 [-binsz <binsize>] [-mean] [-pos <, sep index of chr, pos>] [-ignore <, sep index of columns to ignore>] <bs filename>\n";
}

my $fn=shift @ARGV;
open(IN, "<$fn") or die "cannot open $fn!\n";
$_=<IN>;
chomp;
@l=split("\t", $_);
my $header="chr\tstart\tend";
@values=0..$#l;
my %nonvalues=map { $_ => 1 } (@pos,@ignore);
@values= grep { not $nonvalues{$_} } @values;

for (my $i=0;$i<=$#values;$i++){
  $header.="\t$l[$values[$i]]";
}

while(<IN>){
  chomp;
  @l=split("\t", $_);
  my $binpos=int($l[$pos[1]]/$binsz);
  for (my $i=0;$i<=$#values;$i++){
    if($l[$values[$i]] ne "NA") {
      $sum{$l[$pos[0]]}{$binpos}[$i]+=$l[$values[$i]];
      if($mean){
	    $number{$l[$pos[0]]}{$binpos}[$i]++;
      }
    }
  }
}

print "$header\n";
foreach my $chr (sort keys %sum) {
  foreach my $binpos (sort {$a <=> $b} keys %{$sum{$chr}}) {
    print "$chr\t".($binpos*$binsz+1)."\t".(($binpos+1)*$binsz);
    for (my $i=0;$i<=$#values;$i++){
	my $value=$sum{$chr}{$binpos}[$i];
        if(! defined $value) {$value=0;}
	if($mean){
	  if(! defined $number{$chr}{$binpos}[$i]){
	    $value="NA";
	  }else{
	    $value/=$number{$chr}{$binpos}[$i];
	  }
	}
	print "\t$value";
    }
    print "\n";
  }		
}

