
REM replace the curly bracket contents with appropriate sensitive info
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutChemo.sql -s"," -h-1 -W -o {PATH}\SQL_Chemo_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev_AddOn_Chemo.sql -s"," -h-1 -W -o {PATH}\SQL_Chemo_AddOn.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev_AddOn_MOandRO.sql -s"," -h-1 -W -o {PATH}\SQL_MO_and_RO_AddOn.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutMOandRO.sql -s"," -h-1 -W -o {PATH}\SQL_MO_and_RO_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRev2WeekOutMedicare.sql -s"," -h-1 -W -o {PATH}\SQL_Medicare_WeekOut.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i {PATH}\SchedRevAddOnMedicare.sql -s"," -h-1 -W -o {PATH}\SQL_Medicare_AddOn.csv
C:\Dwimperl\perl\bin\perl.exe {PATH}\Prior-Auths-merge-and-split.pl "{PATH}"  2>perlrunlog.txt