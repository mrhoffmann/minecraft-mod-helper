<#
    config.cfg:
        first line: where you want to put the downloads, full folder directory (C:\temp\mods for example)
        second line: the URI from where you want to download all repositories
    modslist.list:
        auto-generated from the script, should not be touched
    mod-downloader (this):
        execute without changing anything
#>

function Get-ModsList {
    param(
        [Parameter()]
        [string]$source
    )
    
    try{
        if((Test-Path -path ".\modslist.list") -eq $true){
            Remove-Item -Path ".\modslist.list"
        }
        Invoke-WebRequest -URI $source -OutFile ".\modslist.list"
        Start-Sleep -Seconds 3
    }
    catch{
        Write-Error $_.exception
    }
    return test-path -Path ".\modslist.list"
}

function Get-AModFromURI {
    param(
        [Parameter()]
        [string]$source,
        [Parameter()]
        [string]$target
    )

    try{
        $name = ($source -split "/")
        $name = $name[$name.Length -1] -replace "/",""
        Write-Verbose "Working on mod: $name"

        if((test-path -path ".\mods\$name") -eq $false){
            Invoke-WebRequest -URI $source -OutFile ".\mods\$name"
            Start-Sleep -Seconds 2
        }
    }
    catch{
        Write-Error $_.exception
    }
    return (test-path -Path ".\mods\$name")
}

function Invoke-ModDownloader {
    [CmdletBinding()]
    param()

    Clear-Host
    if((test-path -Path ".\config.cfg") -eq $false){
        $errorMsg = "Could not find config.cfg"

        new-item -Path ".\config.cfg"

        if((test-path -Path ".\config.cfg") -eq $false){
            $errorMsg += ", failed generating config file for you."
        }
        else{
            $errorMsg += ", successfully created file for you. On the first row: enter where to save the mods, on the second row, enter URI to mod repository.`n`nExample:`nC:\temp\mods`nhttps://google.com"
        }
        Write-Error $errorMsg
        exit
    }

    $config = Get-Content -Path ".\config.cfg"

    Write-Verbose "Downloading mod-list from $($config[1])"

    if((Get-ModsList -source $config) -eq $true){
        Get-Content -Path ".\modslist.list" | ForEach-Object {
            $_
            if((Get-AModFromURI -source $_) -eq $false){
                Write-Error "Failed downloading $_"
            }
            else{
                Write-Verbose "Successfully downloaded $_"
            }
        }
    }
    else{
        Write-Error "I failed downloading the list."
    }
}

Invoke-ModDownloader