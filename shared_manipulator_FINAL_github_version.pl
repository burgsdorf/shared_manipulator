## Created/modified by I Burgsdorf Apr 2015 (burgsdorf84@gmail.com)
## USAGE: perl -w shared_manipulator.pl ORIGINAL.shared MODIFIED.shared

use strict;
my ($shared_file) = $ARGV[0];
my ($output) = $ARGV[1];
open (my $in1, "<", $shared_file) or die "cannot open $shared_file";
open (my $out, ">>", $output) or die "cannot open $output";

my @arr;
my $counter = 0;
my $number;
my $temporary = "";
my @numbers;
my $line;
my @reads;
my $sum;
my $num;
my $cont = 0;

# Getting queries:
print "What are the OTUs, that you want to extract from this large shared file?
Please provide the names of the OTUs you want to extract (e.g. Otu00001), one in each row. 
You can copy the numbers directly from your Excel file. From the last OTU print enter, ctrl-z (windows) or ctrl-d (MAC, Linux), and enter.\n";
my @OTU_number = <STDIN>;
@OTU_number = grep { $_ ne '' } @OTU_number;    # Delete an empty query if present
chomp @OTU_number;
@OTU_number = sort @OTU_number;

# Procesing of the first line 
$line = <$in1>;                                 # Load first line from the shared file
chomp $line; 
@arr = split(/\s+/, $line);                     # Split line using spaces
my @temporary = @arr;                           # Load all the plited words to the array
print $out "$arr[0] $arr[1] $arr[2] ";          # Print first three words ("label", "Group", "numOtus")

foreach my $OTU_number(@OTU_number) {           # For each OTU number 
	until ($temporary =~ m/$OTU_number/)  {		# Until OTU number is the current OTU number			
		$temporary = shift(@temporary);         # Load OTU number
		$counter = $counter + 1;    			
		$number = $counter - 1;		            # Number of the relevant column in the row (taking into account that the first is 0)
	}
push(@numbers, $number);                        # Put numbers of the relevant columns in the row to the array
}

foreach my $num (@numbers) {	                
	print $out "$arr[$num] ";   				# Print out only names of the relevant OTUs
}

print $out "\n";                                # Go to the next line  

# Procesing of the number of reads (matrix)
$line = <$in1>;                                 # Read next line
while (defined $line) {                                            
	@arr = split(/\s+/, $line);                 # Split line using spaces
	
	foreach my $num (@numbers) {                 
		if (defined $arr[$num]){                	                                     
			push (@reads, $arr[$num]);	        # Push relevant numbers of reads to the array @reads		                            
		}
		else {                                  # In the case that samples will have different number of OTUs fill 0
			push (@reads, 0);
			$cont = 1;			
		}
	}
	if (($sum = eval join '+', @reads) > 0) {	# Print the first three columns and the relevant number of the reads, if sum of all the reads in the row are higher than 0
	print $out "$arr[0] $arr[1] $arr[2] @reads\n";   	
	}                 
	splice @reads;    		                                                                   		
	$line = <$in1>; 							# Read next line
}
if ($cont == 1){
	print $out "\n"; 
	print $out "The samples in the file contain different number of OTUs (numOTUs). Not available numbers of reads could be replaced by 0.";	
}
close ($in1);
close ($out);

