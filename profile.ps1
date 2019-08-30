function ott {Get-Random -maximum 4 -Minimum 1}

function Open-WorkingDirectory{
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
        [Parameter(ValueFromPipeline=$true, Position=0)]
        [string]
        $Path = "."
    )
    
    process{
        if(Test-Path $PATH){
            explorer $Path
        }
        else {
            Write-Error "Path $($Path) not found." -Category InvalidArgument
        }
    }
}

Set-Alias -Name owd -Value Open-WorkingDirectory