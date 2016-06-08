#
#  Perl script Prior-Auths-merge-and-split    Inigo San Gil, June 2016
#  
#  Requisites and dependencies
#     Needs Perl, and CPAN extension Text::CSV_XS
#     The six master files
#     The six new csv files from queries
#     The six completed files to log
#
#  Inputs:  Files path, as argument.  Unix style. I.e  C:/Windows/system32/
#
#  Description:
# 
# For each file (mo/ro; chemo; medicare [ x2] ) :
#
#  -- open master, complete, original.
#     -scan master : completed to completes, others stay.
#     -open daily raw
#     -write out original, [or leave it as is in FS]
#     -parse daily raw. Append to master, adding, minding cols and formatting.
#
#  * originals as come out of SQL job
#
use strict;
use warnings;

my $path = $ARGV[0];

my @master_files = ('MO_and_RO_WeekOut_PriorAuths.csv',
                               'MO_and_RO_AddOn_PriorAuths.csv',
                               'CHEMO_WeekOut_PriorAuths.csv',
                               'CHEMO_AddOn_PriorAuths.csv',
                               'MEDICARE_WeekOut_PriorAuths.csv',
                               'MEDICARE_AddOn_PriorAuths.csv');
                               
foreach my $m_fn (@master_files){
   
     ##  extract completes and pendings from master
     my @completes = get_completes($m_fn);
     
     my @pendings = get_pendings($m_fn);
          
     ## add completes to existing file
     add_completed(\@completes, $m_fn);
     
     ## erase master
     erase_master($m_fn);
     
     ## new master with pending records
     pendings_to_master(\@pendings, $m_fn);
     
     ## get new additions
     my @records = read_new($m_fn);
     
     ## append records
     append_records(\@records, $m_fn);
          
}

sub get_completes
{
   my $master_filename = $path . shift @_;
   
   open my $iom, '<', $master_filename or die "cannot open  $master_filename: $!";

   my @rows;
   
   while (my $master_row = <$iom>) {
      
      my @mrow = split(/,/, $master_row);
      
      if ( $mrow[9] =~ /COMPLETE|DENIED|NO PA(.*)NEEDED|APPEAL/i){
           push @rows, $master_row;
      }
   }
   close $iom or die "no close for  $master_filename: $!";

   return (@rows);
   
}

sub get_pendings
{
   my $master_filename = $path . shift @_;
   
   open my $iom, '<',  $master_filename or die "cannot open  $master_filename: $!";

   my @rows;
   
   while (my $master_row = <$iom>) {
      
      my @mrow = split(/,/, $master_row);
     
      my $var =  $mrow[9] ;   # PCC NOTES is at position 10 cause of the comma separating the last name, first name in the PAT NAME field
      if ( $var !~ /COMPLETE|DENIED|NO PA NEEDED|NO PA\/REF NEEDED|APPEAL/i ) {   #
          push @rows, $master_row;
      }
      
   }
   close $iom or die "no close for $master_filename: $!";

   return (@rows);
   
}

sub add_completed
{
   my @completes = @{$_[0]};
   my $master_filename = $_[1];
   my $complete_fn = $path . 'COMPLETE_' . $master_filename;
  # Open the completes. 
   open my $complete_fh, ">>", $complete_fn or die "$complete_fn: $!"; 
   foreach my $el (@completes)
   {
     print $complete_fh "$el"; 
   }
   close $complete_fh or die "add_completed: Could not close file $complete_fn: $!";
   return;
   
}   

sub  erase_master
{
    my $fname = $path . shift @_;
    unlink  $fname or warn "erase_master: Could not erase  $fname: $!";
    return;
    
}
         
sub pendings_to_master
{
     
   my @rows = @{$_[0]};
   my $master_filename = $path . $_[1];
   
   open my $master_fh, ">>", $master_filename or die "$master_filename: $!"; 

   foreach my $el (@rows)
   {
     print $master_fh "$el"; 
   }
   close $master_fh or die "pendings_to_master: Could not close file  $master_filename: $!";  \
   
   return;
     
}

sub  read_new
{
 
   my $master_filename = shift;
   my $s_fn =  $path . 'SQL_' . $master_filename;   

   open my $ion, '<', $s_fn or die "read_new: Cannot open  $s_fn : $!";

   my @newrows; 
      
   while (my $row = <$ion>) {
      push @newrows, $row;
   }
   
   close $ion or die "no close for $s_fn: $!";
     
   return (@newrows);
}
     
sub append_records
{
   my @newrows = @{$_[0]};  
   my $master_filename = $path . $_[1];

   # Open the master. 
   open my $master_fh, ">>",  $master_filename or die "$master_filename: $!"; 
   
   # Add completes to existing file.
   foreach my $el (@newrows)
   {
     #print "append_record: Row is $el";
     print $master_fh "$el"; # Print each entry in our array to the file
   }
   close $master_fh or die "append_records: Could not close file $master_filename: $!";  \
   return;
}

