<######################################################
 ScriptPurpose: Remediates NICs that are set to be on
     a metered connection
 Author: Mike Horton
 Date: 4/14/2020
######################################################>


$DUSMSvcKey = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\DusmSvc\Profiles" -EA SilentlyContinue
If($null -ne $DUSMSvcKey)
{
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\DusmSvc\Profiles\*" -Recurse -ErrorAction SilentlyContinue
    #Create Scheduled task to force reboot in the middle of the night
    if(Get-ScheduledTask -TaskName MeteredNICReboot -ErrorAction SilentlyContinue)
    {
        Get-ScheduledTask -TaskName MeteredNICReboot | Unregister-ScheduledTask -Confirm:$False
    }
    #Before getting the date make sure that the time isn't currently between 12:00AM and 5:00AM
    [int]$CurrentHour = (Get-Date).ToString("HH")
    If($CurrentHour -lt 5)
    {
        $Date = (Get-Date).ToString('yyyy/MM/dd')
    }else{
        $Date = (Get-Date).AddDays(1).ToString('yyyy/MM/dd')
    }
    $Time = "05:01"
    $action = New-ScheduledTaskAction -Execute C:\Windows\System32\Shutdown.exe -Argument "-r -f -t 60"
    $trigger = New-ScheduledTaskTrigger -Once -At "$Date.$Time"
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "MeteredNICReboot" -User "SYSTEM" -RunLevel Highest -Force | Out-Null
}