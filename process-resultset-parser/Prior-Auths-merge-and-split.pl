#
#  Perl script Prior-Auths-merge-and-split    Inigo San Gil, May 2016
#  
#  Description:
# -- array of filenames (6 master, 6 originals*, 6 completes)
#
# For each file (mo/ro; chemo; medicare [ x2] ) :
#
#  -- open master, complete, original.
#      -scan master : completed to completes, others stay.
#     -open daily raw
#       -write out original, [or leave it as is in FS]
#       -parse daily raw. Append to master, adding, minding cols and formatting.
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

# my ($cfn, $sfn);                                      # filenames

my $m_a; my $s_a;  my $c_a ;                 # contents of file arrays
my ($m_fh, $c_fh , $s_fh);                        # filehandles

foreach my $m_fn (@master_files){
     my $s_fn = 'SQL_' . $m_fn;
     my $c_fn = 'COMPLETE_' . $m_fn;
     
     ## extract completes from master.
     look_up_and_dump_completes($m_fn);
     
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

sub look_up_and_dump_completes
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
   
   ## create a hash of statuses.
   ##my @x = indexes { $_ =~/COMPLETED/ } @column;
     
   # open the completes. create csv object, then add to existing file.
   my $complete_csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });
   my $complete_fn = 'COMPLETE_' . $master_filename;
   open my $complete_fh, ">>", $complete_fn or die "$complete_fh: $!"; 
   $complete_csv->say ($complete_fh, $_) for @completed_rows;
   close $complete_fh or die "could not close file $complete_csv: $!";  
   
   ## open daily SQL raw csv, add to trimmed down master
   
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
    
}
     
     