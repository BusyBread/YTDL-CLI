<#
    .Description
    Collection of functions used to wrap youtube-dl into a Powershell-CLI tool.

    .Notes
    - Created 03/05/2021 by EAM
    - Set-YTDownloadPath
        - Pushes to the set download path.
    - Get-YTContent
        - Is the main function to utlize youtube-dl.exe
    - Test-EmptyString
        - Helper function to check for empty input string.
    - Test-UserYTInput
        - Helper function that checks for either an empty string (Test-EmptyString) or if a default parameter was passed to Get-UserYTInput
    - Get-UserYTInput
        - Is the main command-line interface component, prompts for user input and returns hashtable that is directly used by Get-YTContent
        - CLI defaults can be modifed internally.
    - Get-YTDLEXE
        - Attemps to download youtube-dl.exe from the developers website to a given local path.
#>
function Set-YTDownloadPath {
    param(
        $Path
    )
    try {
        if (-Not(Test-Path -Path $Path)){
            Write-Host "Creating $($DownloadPath) directory..." -ForegroundColor Yellow
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
            Push-Location -Path $Path
        }
    }
    catch {
        Write-Error "Unable to set YT-DL path to $($Path). $($_.Exception.Message)"
    }   
}

function Get-YTContent {
    param(
        [string]$YTDL_Executable,
        [string]$DownloadPath,
        [System.Uri]$URL,
        [ValidateSet('Audio', 'Video')]
        [string]$ContentType = "Audio",
        [string]$Format = "best",
        [switch]$Playlist = $false,
        [switch]$NoThumbnail = $false,
        [switch]$Verbose = $false
    )
    try {
        # set playlist action
        if ($Playlist){
            $playlist_action = "--yes-playlist"
        }
        else {
            $playlist_action = "--no-playlist"
        }

        #set thumbnail action
        if ($NoThumbnail){
            $thumbnail_action = $null
        }
        else {
            $thumbnail_action = " --embed-thumbnail"
        }

        # valid format values
        $format_values = switch($ContentType){
            "Audio" {"best", "mp3", "flac"}
            "Video" {"best", "mp4", "avi"}
        }

        if ($Format -in $format_values){
            # set cmd-line string that gets passed to youtube-dl
            $cmd_string = switch($ContentType){
                # previous audio: "%(artist)s%(title)s.%(ext)s"
                # previous video: "%(artist)s/%(artist)s - %(title)s.%(ext)s"
                "Audio" {
                    $output_template = "%(artist)s%(title)s.%(ext)s"
                    "-i --extract-audio --audio-format {0} --audio-quality 0 -o {1} {2} {3} {4}" -f $Format, $output_template, $playlist_action, $thumbnail_action,$URL
                }
                "Video" {
                    $output_template = "%(channel)s/%(title)s.%(ext)s"
                    "-i -o {0} --format {1} {2} {3}" -f $output_template, $Format, $playlist_action, $URL
                }
            }

            if ($Verbose){
                $cmd_string += " --verbose"
            }

            try {
                if ($Verbose){
                    Write-Host "Execution String: $($cmd_string)" -ForegroundColor Yellow
                }
                
                Write-Host "Attempting to download $($URL) to $($DownloadPath)..." -ForegroundColor Yellow
                Start-Process -FilePath $YTDL_Executable -ArgumentList $cmd_string -NoNewWindow -Wait -WorkingDirectory $DownloadPath
            }
            catch {
                Write-Error "There was an error when running youtube-dl. $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "Invalid format option! Valid Options: {$($format_values)}"
        }
    }
    catch {
        Write-Error "Unable to parse Youtube-DL arguements. $($_.Exception.Message)"
    }
}

function Test-EmptyString {
    param(
        $InputString
    )
    if ($InputString -eq "" -or $InputString -eq " "){
        return $true
    }
    else {
        $false
    }
}

function Test-UserYTInput {
    param(
        $Response,
        $DefaultParam
    )
    if ((Test-EmptyString -InputString $Response) -or $Response -match $DefaultParam){
        return $true
    }
    else {
        return $false
    }
}

function Get-UserYTInput {
    <#
        .Description
        CLI wrapper used to collect parameters for youtube-dl. Returns hashtable that can be passed to the Get-YTContent cmdlet.

        .Notes
        - [VALUE] is the default value for that item.
        - Moved into regions to organize flow.
        - Added default variables to some parameters.
    #>

    #region url
    $url_response = Read-Host -Prompt "Enter URL"
    if ($url_response -match "^https"){
        $yt_args = @{"URL" = $url_response}
    }
    elseif ($url_response -match "q|quit") {
        Write-Host "Quitting..." -ForegroundColor Red
        break
    }
    else {
        Write-Warning "$($url_response) is not a valid URL."
        break
    }
    #endregion url

    #region content type
    $default_content = "Audio"
    $content_response = (Read-Host -Prompt "Download as video or audio? [$($default_content)]")
    if (Test-UserYTInput -Response $content_response -DefaultParam $default_content){
        $yt_args.Add("ContentType", $default_content)
    }
    else {
        $yt_args.Add("ContentType", "Video")
    }
    #endregion content type

    #region format
    $default_format = switch($yt_args.ContentType){
        "Audio" {"mp3"}
        "Video" {"mp4"}
    }
    $format_response = (Read-Host -Prompt "Enter desired $($yt_args.ContentType) format [$($default_format)]").ToLower()
    if (Test-UserYTInput -Response $format_response -DefaultParam $default_format){
        $yt_args.Add("Format", $default_format)
    }
    else {
        $yt_args.Add("Format", $format_response)
    }
    #endregion format

    #region playlist
    $playlist_response = Read-Host "Download as playlist? [No]"
    if (Test-UserYTInput -Response $playlist_response -DefaultParam "No"){
        $yt_args.Add("Playlist", $false)
    }
    else {
        $yt_args.Add("Playlist", $true)
    }
    #endregion playlist

    #region thumbnail -- only if audio
    if ($yt_args.ContentType -eq "Audio"){
        $thumbnail_response = Read-Host "Embed thumbnail? [Yes]"
        if (Test-UserYTInput -Response $thumbnail_response -DefaultParam "Yes"){
            $yt_args.Add("NoThumbnail", $false)
        }
        else {
            $yt_args.Add("NoThumbnail", $true)
        }
    }
    #endregion thumbnail -- only if audio

    #region verbose
    $verbose_response = Read-Host "Verbose Output? [No]"
    if (Test-UserYTInput -Response $verbose_response -DefaultParam "No"){
        $yt_args.Add("Verbose", $false)
    }
    else {
        $yt_args.Add("Verbose", $true)
    }
    #endregion verbose

    return $yt_args
}

function Get-YTDLEXE {
    param(
        $DownloadUrl = 'https://yt-dl.org/downloads/2021.03.03/youtube-dl.exe',
        $LocalYTPath = (Join-Path -Path $env:LOCALAPPDATA -ChildPath "youtube-dl")
    )
    try {
        # create parent dir if not already there
        if (-Not( Test-Path -Path (Split-Path -Path $LocalYTPath -OutVariable local_dir) )){
            Write-Host "Creating $($local_dir) directory..." -ForegroundColor Yellow
            New-Item -Path $local_dir -ItemType Directory -Force | Out-Null
        }

        # append excutable name to path if not already there
        if ($LocalYTPath -notmatch "exe$"){
            $LocalYTPath = Join-Path -Path $LocalYTPath -ChildPath "youtube-dl.exe"
        }

        Invoke-WebRequest -Uri $DownloadUrl -OutFile $LocalYTPath -Verbose -OutVariable content_status

        if (Test-Path $LocalYTPath){
            Write-Host "File appears to have completed downloading. Try to run the script again." -ForegroundColor Green
            return $trues
        }
        else {
            Write-Warning "Could not locate file. Try to manually download file."
            return $false
        }
    }
    catch {
        Write-Error "There was an error attempting to download youtube-dl.exe. $($_.Exception.Message)"
    }
}