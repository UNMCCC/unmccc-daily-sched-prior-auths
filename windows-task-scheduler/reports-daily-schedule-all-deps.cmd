REM replace the curly bracket contents with appropriate sensitive info
copy {PATH}\MO_and_RO*csv  {PATH}\Programs\
copy {PATH}\Chemo*.csv      {PATH}\Programs\
copy {PATH}\Medicare*csv   {PATH}\Programs\
copy {PATH}\MO_and_RO_WeekOut.csv  {PATH}\Backups\MO_and_RO_WeekOut%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
copy {PATH}\Chemo_WeekOut.csv      {PATH}\Backups\Chemo_WeekOut%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
copy {PATH}\Medicare_WeekOut.csv   {PATH}\Backups\Medicare_WeekOut%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
copy {PATH}\MO_and_RO_AddOn.csv  {PATH}\Backups\MO_and_RO_AddOn%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
copy {PATH}\Chemo_AddOn.csv      {PATH}\Backups\Chemo_AddOn%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
copy {PATH}\Medicare_AddOn.csv   {PATH}\Backups\Medicare_AddOn%date:~-4,4%_%date:~-10,2%_%date:~-7,2%.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutChemo.sql -s"," -h-1 -W -o {PATH}\SQL_Chemo_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev_AddOn_Chemo.sql -s"," -h-1 -W -o {PATH}\SQL_Chemo_AddOn.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev_AddOn_MOandRO.sql -s"," -h-1 -W -o {PATH}\SQL_MO_and_RO_AddOn.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutMOandRO.sql -s"," -h-1 -W -o {PATH}\SQL_MO_and_RO_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutMedicare.sql -s"," -h-1 -W -o {PATH}\SQL_Medicare_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRevAddOnMedicare.sql -s"," -h-1 -W -o {PATH}\SQL_Medicare_AddOn.csv
C:\Dwimperl\perl\bin\perl.exe {PATH}\Prior-Auths-merge-and-split.pl "{PATH}"  2>perlrunlog.txt
copy  {PATH}\MO*csv  {PATH\..}
copy  {PATH}\Chemo*csv  {PATH\..}
copy  {PATH}\Medicare*csv  {PATH\..}