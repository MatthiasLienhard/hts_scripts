#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;

my @line;
my %table;
my @header=("id_1");
my @nrValues;
my $na="NA";
my @n;
my $cut;
my $head=1;
my $val_i="all";
my $idx_i=0;
my $count=0;
my $skip=0;
my $sep="\t";
my $del="\t";
my $comment;
GetOptions ("comment=s"=>\$comment,"cut=s" => \$cut,"na=s" => \$na,"val=s"=>\$val_i, "header!"=>\$head,"sep=s"=>\$sep, "idx=s"=>\$idx_i, "skip=i"=>\$skip, "del=s"=>\$del );
if (defined $comment){$comment =quotemeta $comment}
@n=@ARGV;
if($#ARGV <= 0) {
	die "$0 [-cut patterns] [-header/noheader] [-comment <comment pattern, default: non>] [-skip <number of lines to skip, default:0>] [-idx <idx of id column(s), default:0>] [-val <idx of value columns, default:all>] [-sep <input delimiter>] [-del <output delimiter>] [-na <NA-value, default=NA>] <file1> <file2> ...\n";
}


my @id_idx=split(",",$idx_i);
#print join(", ",grep(/\D+/, @id_idx))."\n";
if (scalar grep(/\D+/, @id_idx)>0){
  die "value columns must be integer and comma seperated\nexample: -id 0,1,2 for a concatination of the first 3 columns\n";
}
#print join(", ", @id_idx)."\n";
my @val_idx;

if( $val_i ne "all"){ 
  @val_idx=split(",",$val_i);
  if (scalar grep(/\D+/, @val_idx)>0){
    die "value columns must be integer and comma seperated\nexample: -val 1,2,9,3,5\n";  
  }
}

for (my $i=0;$i < scalar @ARGV;$i++){
  my  ($name,$path,$suffix) = fileparse($n[$i]);
  $n[$i]=$name;
  if (defined $cut){
    foreach (split(",",$cut)){
      my @tmp=split ($_,$n[$i]);
      $n[$i]=join("",@tmp); 
      #print "name: $n[$i]\n";
    }
  }
}
$header[0]="id_".$id_idx[0];
if($#id_idx>0){
  for my $nr (@id_idx[1 .. $#id_idx]){
    $header[0]=$header[0].$del."id_".$nr;
  }
}

for(my $i = 0; $i < scalar @ARGV; $i++) {
	print STDERR "reading $ARGV[$i]\n";
	open(IN, "<$ARGV[$i]") or die "cannot open $ARGV[$i]!\n";
	for(my $skipI=0;$skipI<$skip;$skipI++){
	  <IN>;
	}
        $_=<IN>;
	
	if(defined $comment){
		while($_ =~ m{$comment} && defined $_){$_=<IN>}
	}
	chomp $_;
	@line=split($sep, $_);
	if($val_i eq "all"){
	    @val_idx=grep{ not $_ ~~ @id_idx } (0 .. $#line);
	}	  
	$nrValues[$i]=scalar @val_idx;
	if ($head){	  
	  if ($line[0] eq "logFC" ){
	    unshift (@line,"id");
	    if($val_i eq "all"){
	      @val_idx=grep{ not $_ ~~ @id_idx } (0 .. $#line);
	    }	
	    $nrValues[$i]=scalar @val_idx;
	  }
	  $header[$i+1] = "$n[$i]_".join ("\t$n[$i]_", @line[@val_idx]);
	  $_=<IN>; 
	}elsif($nrValues[$i]>1){
	  $header[$i+1] = "$n[$i]_".join ("\t$n[$i]_", @val_idx)
	}else{
	  $header[$i+1] = $n[$i]
	}
	do{	
		if(! defined $comment || $_ !~ m{$comment}){
			chomp;
			@line = split($sep, $_);
			$table{join($del,@line[@id_idx])}[$i] = join ($del, @line[@val_idx]);
			$count++;
		}
	}while(<IN> ); # && chomp && (@line = split));
	close(IN);
}

print join($del, @header)."\n";

foreach my $key (sort keys %table) {
	print $key;
	
	
	for(my $i = 0; $i < scalar @ARGV; $i++) {
	  
		if(defined $table{$key}[$i]) {
			print $del . $table{$key}[$i];
		}
		else {
			print (($del.$na) x $nrValues[$i]);
		}
	}
	print "\n";
	
}
#print "$count\n"



