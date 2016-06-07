## Automatization of the Daily Schedule for Prior Auths

### Overview : This project implements the prior authorization (PA) process. Particularly, the pieces here simplify and eliminate the preliminary steps:

-Adapts the seeding *Review Daily Schedule All Depts* database report by filtering fields, breaking it down into separate sheets.

-Merges daily results into the master spreadsheets that contain PAs being in the resolution process.
  
-Moves resolved PA cases into an archive for further reporting.

These enhancements include SQL Server queries, a resulset parser coded in Perl and a batch job in the windows scheduler.

### Dependencies:

- Mosaiq 2.65 or better.
- Underlying Windows stack. UNMCCC usage customizations and workflows of the daily schedules.
- sqlcmd: the command line of MS SQL server.
- Windows Task scheduler. 
- Perl, a vanilla distro without any extra modules would do.

### Configurations.  

Special attention needs to be placed to adapt paths of these files, master spreadsheets, authentication to reach these resources and server directing the automated workflow.

### Tests.

Tests conducted with staff and leaders to match results with current deployed semi-manual ops.

### Integration with larger vision.  Ideally the process would be deprecated with a more agile, API that tracks the workflow of info.  

