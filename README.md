# Invoke-YTDL
PowerShell command-line tool that allows you to download your favorite Youtube videos in either a video or audio format.

## Requirements
- Install ffmpeg and add to $PATH.
- Local instance of youtube-dl.exe (script will attempt to download latest version from developers site)

## Usage
* Download zip and extract to any local directory.
* Modify Invoke-YTDL.ps1 variables to suit your environment.
	* YTDL_Executable
		* Path to the local instance of youtube-dl.exe.
		* If not already present in path given the script will attempt to download the latest version from the developers site.
	* DownloadPath
		* Path to save downloaded files, if not already present the script will attempt to create the directory.
		* Defaults to `%USERPROFILE%\Downloads\yt_downloads`
* Run Invoke-YTDL.ps1 directly from PowerShell console or double-click provided batch file.

## Screenshots
* Downloading youtube-dl.exe.

![Downloading youtube-dl.exe](https://github.com/BusyBread/YTDL-CLI/blob/main/images/downloading_youtube-dl.png)


* Completed youtube-dl.exe download.

![Completed download](https://github.com/BusyBread/YTDL-CLI/blob/main/images/completed_downloading_youtube-dl.png)


* Downloaded audio file.

![Downloaded audio file](https://github.com/BusyBread/YTDL-CLI/blob/main/images/download_audio_file.png)


* Downloaded video file (verbose).

![Downloaded video file (verbose)](https://github.com/BusyBread/YTDL-CLI/blob/main/images/download_video_file_verbose.png)
