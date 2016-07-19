/*Apr 2016: For Cheryl Moya's group -- Prior Authorizations.
-Adapts to include MEDICARE only
-Add-ons
---- appts made yesterday 
-----DOS to be between today to 2weeks
-Revised Jun 2016 - spurious fields, comments and left-outers.*/

SET NOCOUNT ON;
DECLARE @TwoWeeksOut VARCHAR(10);
DECLARE @Today VARCHAR(10)
DECLARE @Yesterday VARCHAR(8);

Set @TwoWeeksOut = CONVERT(VARCHAR(10),dateadd(DAY,13,GETDATE()),112);
Set @Today = CONVERT(VARCHAR(10),GETDATE(),112);
--Set @Yesterday = CONVERT(VARCHAR(10),dateadd(DAY,-1,GETDATE()),112);
Set @Yesterday = CONVERT(VARCHAR(10),DATEADD(DAY, CASE (DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST) % 7 
                        WHEN 1 THEN -2 
                        WHEN 2 THEN -3 
                        ELSE -1 
                    END, DATEDIFF(DAY, 0, GETDATE())),112);
SELECT DISTINCT CONVERT(CHAR(10),Sch.APP_DTTM,101) AS [APPT DATE], 
--CONVERT(CHAR(10),Sch.Create_DtTm, 101) AS CREATED,
IDA AS [MRN], 
QUOTENAME(dbo.fn_GetPatientName(PAT.Pat_ID1, 'NAMELFM'), '"')  AS PAT_NAME,
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
(    Staff.Last_Name not like '%Desk%'
	and Staff.staff_id != 1045 --Last_Name not like 'RO Front%'
    and Staff.Staff_ID != 728 --and Staff.Last_Name not like '%3rd Floor Lobby%'
	and Staff.Staff_ID != 1478) --and Staff.Last_Name not like '%3rd Floor Treatment%'
	
and (sch.Activity NOT LIKE '%psyintern%'
	AND sch.Activity NOT LIKE '%wound%' 
	AND sch.Activity NOT LIKE '%note%'
	AND sch.Activity NOT LIKE '%nurse%' 
	AND sch.Activity NOT LIKE '%nutri%' 
	AND sch.Activity NOT LIKE '%NuCon%' 
	AND sch.Activity NOT LIKE 'MEDRC'
	AND sch.Activity NOT LIKE 'Fin%')
	and IDA not in ('', '0000') 
	and sch.Version = 0

  AND CONVERT(CHAR(8),SCH.APP_DTTM,112) >= @Today
  AND CONVERT(CHAR(8),SCH.APP_DTTM,112) <= @TwoWeeksOut
  AND CONVERT(CHAR(8),SCH.Create_DtTm,112) = @Yesterday

and General_Primary_Payer_ID =756  --  Medicare OP only

ORDER BY PAT_NAME, 
[APPT DATE]


