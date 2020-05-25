<######################################################
 ScriptPurpose: Check that the computer's NIC is set to
    a metered connections
 Author: Mike Horton
 Date: 4/6/2020
######################################################>

#If ($MeteredAction -eq "MeteredOn") { $MeteredChoice = 2 } else { $MeteredChoice = 0 }
$DUSMSvcKey = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\DusmSvc\Profiles" -EA SilentlyContinue
If($null -ne $DUSMSvcKey)
{
    Foreach($regObj in $DUSMSvcKey)
    {
        $regKey = $regObj.Name
        $regKey = $regKey -replace "HKEY_LOCAL_MACHINE", "HKLM:"
        $UserCost = Get-ItemProperty -Path "$($regKey)\*" -Name UserCost -EA SilentlyContinue
        If($UserCost.UserCost -ne 0)
        {
            return $true
        }
    }
}
return $false