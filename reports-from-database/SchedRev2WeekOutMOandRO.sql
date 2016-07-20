/*Apr 2016: For Cheryl Moya's group -- Prior Authorizations.
-Adapts to include MO+RO only
-Week Out (+14)
-App Created since a year ago
--Excludes appt. created yesterday.
-Revised Jun 2016 - spurious fields, comments and left-outers.
*/
SET NOCOUNT ON;
DECLARE @TwoWeeksOut VARCHAR(10);
DECLARE @YearAgo VARCHAR(8);
DECLARE @Yesterday VARCHAR(8);

Set @TwoWeeksOut = CONVERT(VARCHAR(10),dateadd(DAY,14,GETDATE()),112);
Set @YearAgo = CONVERT(VARCHAR(10),dateadd(YEAR,-1,GETDATE()),112);
Set @Yesterday = CONVERT(VARCHAR(10),DATEADD(DAY, CASE (DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST) % 7 
  WHEN 1 THEN -2 
  WHEN 2 THEN -3 
  ELSE -1 
END, DATEDIFF(DAY, 0, GETDATE())),112);

SELECT DISTINCT CONVERT(CHAR(10),Sch.APP_DTTM,101) AS [APPT DATE], 
IDA AS [MRN], 
 QUOTENAME(dbo.fn_GetPatientName(PAT.Pat_ID1, 'NAMELFM'), '"') AS PAT_NAME,
Staff.Last_Name AS [LOCATION], 
sch.ACTIVITY, 
General_Primary_Payer_Name as PrimPayer,
sch.Notes as [NOTES]

from 
 Schedule Sch WITH(NOLOCK)
LEFT OUTER JOIN Admin A WITH(NOLOCK) ON Sch.Pat_ID1 = A.Pat_ID1
LEFT OUTER JOIN vw_PatientInsurances VWPAT WITH(NOLOCK) ON Sch.Pat_ID1 = VWPAT.Pat_ID1
LEFT OUTER JOIN vw_Patient PAT WITH(NOLOCK) ON Sch.PAT_ID1 = PAT.pat_id1
left outer join Staff with(nolock) on Sch.Location = Staff.Staff_ID
left outer join Staff S1 with(nolock) on Sch.Staff_ID = S1.Staff_ID

WHERE
(  Staff.Last_Name not like '%Desk%'
	and Staff.staff_id != 1045 --Last_Name not like 'RO Front%'
    and Staff.Staff_ID != 728 --and Staff.Last_Name not like '%3rd Floor Lobby%'
	and Staff.Staff_ID != 1478 --and Staff.Last_Name not like '%3rd Floor Treatment%'
	and Staff.Last_Name not like '%hair%'
	and Staff.Last_Name not like '%Bed%'
	 and Staff.Last_Name NOT LIKE '%Shot Clinic%')
	
and (sch.Activity NOT LIKE '%psyintern%'
	AND sch.Activity NOT LIKE '%wound%' 
	AND sch.Activity NOT LIKE '%note%'
	AND sch.Activity NOT LIKE '%nurse%' 
	AND sch.Activity NOT LIKE '%nutri%' 
	AND sch.Activity NOT LIKE '%NuCon%' 
	--AND Activity NOT LIKE '%lbcon%'/*not billable per Ballinger, lab draw*/
	AND sch.Activity NOT LIKE 'MEDRC'
	AND sch.Activity NOT LIKE 'Fin%')
	and IDA not in ('', '0000') 
	and sch.Version = 0

AND CONVERT(CHAR(8),SCH.APP_DTTM,112) = @TwoWeeksOut
AND CONVERT(CHAR(8),SCH.Create_DtTm,112) >= @YearAgo
AND CONVERT(CHAR(8),SCH.Create_DtTm,112) < @Yesterday

 -- exclude UNM Care Co-Pays T00, T05, T10 and T20
  and General_Primary_Payer_ID !=701
  and General_Primary_Payer_ID !=703
  and General_Primary_Payer_ID !=705
  and General_Primary_Payer_ID !=706
   -- excludes 901,905,910 and 920
 and General_Primary_Payer_ID  NOT between 680 and 685
  -- excludes SRMC Care Prog 100% discount AND Self Py INS NOT..
  and General_Primary_Payer_ID  NOT between 779 and 780

  and General_Primary_Payer_ID !=756  --  NOT Medicare OP 

ORDER BY PAT_NAME, 
[APPT DATE]


