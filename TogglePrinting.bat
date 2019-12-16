@echo off

sqlcmd -S "localhost\LS1" -U "sa" -P "c0nn3ct?" -d "LSONE_CTC" -Q "SET NOCOUNT ON; UPDATE [POSISFORMLAYOUT] SET [PRINTBEHAVIOUR] = CASE WHEN [PRINTBEHAVIOUR] = '1' THEN '0' WHEN [PRINTBEHAVIOUR] = '0' THEN '1' END WHERE [DESCRIPTION]='AU_Receipt'"

for /f %%a in ('sqlcmd -S "localhost\LS1" -U "sa" -P "c0nn3ct?" -d "LSONE_CTC" -Q "SET NOCOUNT ON; SELECT [PRINTBEHAVIOUR] from [POSISFORMLAYOUT] WHERE [DESCRIPTION]='AU_Receipt'"') do set pri=%%a

if %pri% == 0 echo Printer is now disabled!
if %pri% == 1 echo Printer is now enabled!

TIMEOUT 3