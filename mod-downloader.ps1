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
        [string]$dest,
        [Parameter()]
        [string]$source
    )

    Remove-Item -Path ".\modslist.list"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($source, $dest)
    sleep 2
    return test-path -Path $dest
}

function Get-AModFromURI {
    param(
        [Parameter()]
        [string]$source,
        [Parameter()]
        [string]$target
    )

    $name = ($source -split "/")
    $name = $name[$name.Length -1] -replace "/",""
    Write-Verbose "Working on mod: $name"
    
    if((test-path -path "$target\$name") -eq $false){
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($source, "$target\$name")
        sleep 2
    }
    return test-path -Path "$target\$name"
}

function Get-MyMods {
    [CmdletBinding()]
    param()

    cls
    if((test-path -Path ".\config.cfg") -eq $false){
        $error = "Could not find config.cfg"

        new-item -Path ".\config.cfg"

        if((test-path -Path ".\config.cfg") -eq $false){
            $error += ", failed generating config file for you."
        }
        else{
            $error += ", successfully created file for you. On the first row: enter where to save the mods, on the second row, enter URI to mod repository."
        }
        Write-Error $error
        exit
    }

    $modslist = ".\modslist.list"
    $config = gc -path ".\config.cfg"

    Write-Verbose "Downloading mod-list from $($config[1])"

    if((Get-ModsList -dest $modslist -source $config[1]) -eq $true){
        gc -Path $modslist | % {
            if((Get-AModFromURI -source $_ -target $config[0] -Verbose) -eq $false){
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

Get-MyMods -Verbose