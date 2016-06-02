
REM replace the curly bracket contents with appropriate sensitive info
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRev2WeekOutChemo.sql -s"," -h-1 -W -o SQL_CHEMO_WeekOut_PriorAuths.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRev_AddOn_Chemo.sql -s"," -h-1 -W -o SQL_CHEMO_AddOn_PriorAuths.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRev_AddOn_MOandRO.sql -s"," -h-1 -W -o SQL_MO_and_RO_AddOn_PriorAuths.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRev2WeekOutMOandRO.sql -s"," -h-1 -W -o SQL_MO_and_RO_WeekOut_PriorAuths.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRev2WeekOutMedicare.sql -s"," -h-1 -W -o SQL_MEDICARE_WeekOut_PriorAuths.csv
sqlcmd -U {user} -P{passwd} -S {DBInstance} -i SchedRevAddOnMedicare.sql -s"," -h-1 -W -o SQL_MEDICARE_AddOn_PriorAuths.csv
C:\Dwimperl\perl\bin\perl.exe Prior-Auths-merge-and-split.pl