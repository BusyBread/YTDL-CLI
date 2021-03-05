<#
    .Description
    This command-line tool will allow you to download your favorite Youtube videos as videos or songs.

    .Parameter YTDL_Executable
    Path to your local instance of youtube-dl.exe. If not already present in path given the script will attempt to download the latest
    version from the developers site. See Get-YTDLEXE function for more. Default path is %localappdata%\youtube-dl

    .Parameter DownloadPath
    Path to save downloaded files, if not already present the script will attempt to create the directory. Defaults folder to users Downloads.

    .Parameter YT_Module
    Path to ytdl.psm1

    .Notes
    Created 03/05/2021 by EAM
#>
param(
    $YTDL_Executable = (Join-Path -Path $env:LOCALAPPDATA -ChildPath "youtube-dl\youtube-dl.exe"),
    $DownloadPath = (Join-Path -Path $env:USERPROFILE -ChildPath "Downloads\yt_downloads"),
    $YT_Module = (Join-Path -Path $PWD -ChildPath "src\ytdl.psm1")
)
try {
    Start-Transcript -Path (Join-Path -Path $env:TEMP -ChildPath "$(Get-Date -Format 'MMdd')$($MyInvocation.MyCommand.Name).log") -Force -Append -NoClobber
    Import-Module $YT_Module

    if (Test-Path $YTDL_Executable){
        Set-YTDownloadPath -Path $DownloadPath
        $count = 0
        while($true){
            $yt_params = Get-UserYTInput
            Get-YTContent -YTDL_Executable $YTDL_Executable -DownloadPath $DownloadPath @yt_params
            Write-Host "$($yt_params.URL) appears to have completed downloading...." -ForegroundColor Green
            Start-Sleep -Milliseconds 1500
            $count++
            Clear-Host
        }
        Write-Host "File Count: $($count)." -ForegroundColor Cyan
        Start-Sleep -Milliseconds 1500
    }
    else {        
        Write-Warning "$($YTDL_Executable) could not be found. Attempting to download..."
        Start-Sleep -Milliseconds 500
        Get-YTDLEXE -LocalYTPath $YTDL_Executable
    }
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    Pop-Location
    Remove-Module ytdl
    Stop-Transcript | Out-Null
}
