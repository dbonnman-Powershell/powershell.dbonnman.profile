$PSPersonalProfileFolder = (get-item $profile.CurrentUserAllHosts).DirectoryName

# 1, 2, 3
function ott { Get-Random -maximum 4 -Minimum 1 }

function Open-WorkingDirectory {
    <#
    .SYNOPSIS
        Open filesystem path in Windows explorer
    .DESCRIPTION
        This function enables comfortably opening folder paths in Windows explorer. If no path is specified, the current working directory is opened. 
        Multiple Paths can be provided via Pipeline.
    .EXAMPLE
        PS C:\> Open-WorkingDirectory
        Opens the current working directory in Windows Explorer
    .EXAMPLE
        PS C:\> Open-WorkingDirectory C:\Path\To\Folder
        Opens the specified folder in Windows Explorer
    .INPUTS
        Path - The file path to open (defaults to pwd if empty)
    .OUTPUTS
        None
    .NOTES
        Author: Dennis Bonnmann (dennis.bonnmann@materna.de)
    #>
    param(
        # Path to open. Defaults to CWD
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [string]
        $Path = "."
    )
    
    process {
        if (Test-Path $Path) {
            explorer $Path
        }
        else {
            Write-Error "Path $($Path) not found." -Category InvalidArgument
        }
    }
}


Set-Alias -Name owd -Value Open-WorkingDirectory

function Get-TimeWorked {
    <#
    .SYNOPSIS
        Outputs the length of time worked based on when you clocked in
    .DESCRIPTION
        This cmdlet calculates the length of time from clocking in in the morning till now.
        It therefore takes a timestamp in a 24h military format, e.g. 0800 for 8 am.
        Legally required breaks will be automatically factored in
    .EXAMPLE
        PS C:\> Get-TimeWorked -ClockedIn 0800
        Computes the length of time worked from 8 am till now
    .NOTES
        Author: Dennis Bonnmann (dennis.bonnmann@materna.de)
    .ALIAS
        clock
    #>
    [CmdletBinding()]
    param (
        # The time you clocked in to TiC in a 24 hr military format.
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateRange(0, 2359)]
        [Int]
        $ClockedIn,
        # Parameter help description
        [Parameter()]
        [Switch]
        $Feierabend = $false
    )
    
    begin {
        
    }
    
    process {
        $CurrentTime = Get-Date
        $ClockedInHrs = [System.Math]::Floor($ClockedIn / 100)
        $ClockedInMins = $ClockedIn % 100
        $ClockedIntDateObject = New-Object System.DateTime(
            $CurrentTime.Year,
            $CurrentTime.Month,
            $CurrentTime.Day,
            $ClockedInHrs,
            $ClockedInMins,
            0
        )
        Write-Verbose "Clocked in at $($ClockedIntDateObject.TimeOfDay)"
        if($Feierabend){
            $FeierabendTime = $ClockedIntDateObject.AddHours(8).AddMinutes(30)
            $TimeToFeierabend = $FeierabendTime.Subtract($CurrentTime)
            "You can go home at $($FeierabendTime.TimeOfDay) (Time remaining: $($TimeToFeierabend.ToString("hh\:mm")))"
        }

        Write-Verbose "It is now $($CurrentTime.TimeOfDay)"

        $TimeWorked = $CurrentTime.Subtract($ClockedIntDateObject)

        if ($TimeWorked.Hours -ge 6) {
            $ClockedIntDateObject = $ClockedIntDateObject.AddMinutes(30)
            Write-Verbose "You worked more than 6 hours. Adding 30 minute break"
        }
        if ($TimeWorked.Hours.Hours -ge 9) {
            $ClockedIntDateObject = $ClockedIntDateObject.AddMinutes(15)
            Write-Verbose "You worked more than 9 hours. Adding 15 minute break"
        }

        $TimeWorked = $CurrentTime.Subtract($ClockedIntDateObject)
        "You have worked for $($TimeWorked.toString("hh\:mm"))"
        if ($TimeWorked.Hours -ge 8) {
            "You can go home :-)"
        }
    }
    
    end {
        
    }
}

Set-Alias -Name clock -Value Get-TimeWorked

function Connect-One{
    Connect-VIServer -Server vcsa-one -Credential (Import-Clixml "H:\Scripting\VMware\cred.xml")
}