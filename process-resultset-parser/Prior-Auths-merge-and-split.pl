#
#  Perl script Prior-Auths-merge-and-split    Inigo San Gil, May 2016
#  
#  Description:
# -- array of filenames (6 master, 6 originals*, 6 completes)
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

my @master_files = ('MO_and_RO_WeekOut_PriorAuths.csv',
                               'MO_and_RO_AddOn_PriorAuths.csv',
                               'CHEMO_WeekOut_PriorAuths.csv',
                               'CHEMO_AddOn_PriorAuths.csv',
                               'MEDICARE_WeekOut_PriorAuths.csv',
                               'MEDICARE_AddOn_PriorAuths.csv');
                               
#my @completed_files = ('COMPLETE_MO_and_RO_WeekOut_PriorAuths.csv',   'COMPLETE_MO_and_RO_AddOn_PriorAuths.csv',    'COMPLETE_CHEMO_WeekOut_PriorAuths.csv', 'COMPLETE_CHEMO_AddOn_PriorAuths.csv',    'COMPLETE_MEDICARE_WeekOut_PriorAuths.csv', 'COMPLETE_MEDICARE_AddOn_PriorAuths.csv');
             
#my @original_files = ('SQL_MO_and_RO_WeekOut_PriorAuths.csv', 'SQL_MO_and_RO_AddOn_PriorAuths.csv',  'SQL_CHEMO_WeekOut_PriorAuths.csv',  'SQL_CHEMO_AddOn_PriorAuths.csv',  'SQL_MEDICARE_WeekOut_PriorAuths.csv',    'SQL_MEDICARE_AddOn_PriorAuths.csv');

my $m_a; my $s_a;  my $c_a ;                 # contents of file arrays
my ($m_fh, $c_fh , $s_fh);                        # filehandles

foreach my $m_fn (@master_files){
   
     ##  extract completes and pendings from master
     (my @completes, my @pendings) = get_completes_and_pendings($m_fn);
     
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
     
     ## reporting
     ##
}

sub slurp
{
    my $filename = shift;
    open my $in, '<', $filename
        or die "Cannot open '$filename' for slurping - $!";
    local $/;
    my $contents = <$in>;
    close($in);
    return $contents;
}

sub get_completes_and_pendings
{
   use Text::CSV_XS;
  ## use List::MoreUtils;
   
   my $master_filename = shift;
   my $csv = Text::CSV_XS->new ({ binary => 1 });

   open my $iom, "<", $master_filename or die "cannot open $master_filename: $!";

   ##get only the 7th column 
   ##my @column = map { $_->[6] } @{$csv->getline_all ($iom)};
   my @completed_rows; my @pending_rows;
   while (my $master_row = $csv->getline ($iom)) {
      if( $master_row->[6] =~ m/COMPLETED/ ){  # 7th field should match
                                                                               ### HERE, get me the statuses.
         push @completed_rows, $master_row;
         ## get me the person who completed, add to counter.  HERE
      }else{
         push @pending_rows, $master_row;
      }
   }
   close $iom or die "no close for $master_filename: $!";

   return (\@completed_rows, \@pending_rows);
   
}
 
sub add_completed
{
   my @completes = @{$_[0]};
   my $master_filename = $_[1];
   my $complete_fn = 'COMPLETE_' . $m_fn;    
  # Create csv object
   my $complete_csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });
   
  # Open the completes. 
   my $complete_fn = 'COMPLETE_' . $master_filename;
   open my $complete_fh, ">>", $complete_fn or die "$complete_fh: $!"; 
   # Add completes to existing file.
   $complete_csv->say ($complete_fh, $_) for @completes;
   close $complete_fh or die "add_completed: Could not close file $complete_fn: $!";  \
   
   return;
   
}   

sub  erase_master
{
    my $fname = shift;
    unlink $fname or warn "erase_master: Could not erase $fname: $!";
    return;
    
}
         
sub pendings_to_master
{
   my @rows = @{$_[0]};
   my $master_filename = $_[1];
   # Create csv object
   my $work_csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });
   
   # Open the new master filename
   open my $master_fh, ">>", $master_filename or die "$master_filename: $!"; 
   # Add pendings to master
   $work_csv->say ($master_fh, $_) for @rows;
   close $master_fh or die "pendinds_to_master: Could not close file $master_filename: $!";  \
   
   return;
     
}

sub  read_new
{
   my $master_filename = shift;
   my $s_fn = 'SQL_' . $master_filename;
   
   my $csv = Text::CSV_XS->new ({ binary => 1 });
   open my $ion, "<", $s_fn or die "cannot open $s_fn : $!";

   my @new_rows; 
   while (my $row = $csv->getline ($ion)) {
      
      push @new_rows, $row;
      
   }
   close $ion or die "no close for $s_fn: $!";
     
   return (\@newrows);
}
     
sub append_records
{
   my $newrows = @{$_[0]};  
   my $master_filename = $_[1];
    
   # Create csv object
   my $master_csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });
  # Open the master. 
   my $master_fn = $master_filename;
   open my $master_fh, ">>", $master_fn or die "$master_fn: $!"; 
   
   ##may be i need to add-take to newrows here.
   ##
   ##  
   # Add completes to existing file.
   $master_csv->say ($master_fh, $_) for @newrows;
   close $master_fh or die "append_records: Could not close file $master_filename: $!";  \
   return;
}