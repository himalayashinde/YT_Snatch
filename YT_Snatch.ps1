Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# Prompt the user for the YouTube playlist URL
$playlistUrl = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the YouTube Playlist URL:", "YouTube Downloader")

if ([string]::IsNullOrWhiteSpace($playlistUrl)) {
    Write-Host "No URL entered. Exiting..."
    exit
}

# Set output directory dynamically to user's Downloads folder
$outputDir = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("UserProfile"), "Downloads", "YT-Downloads")
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }

# Create a GUI form for selecting format
$popup = New-Object System.Windows.Forms.Form
$popup.Text = "Select Download Format"
$popup.Size = New-Object System.Drawing.Size(300, 150)
$popup.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Do you want to download Audio or Video?"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(50, 20)
$popup.Controls.Add($label)

$audioButton = New-Object System.Windows.Forms.Button
$audioButton.Text = "Audio"
$audioButton.Location = New-Object System.Drawing.Point(50, 60)
$audioButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$popup.Controls.Add($audioButton)

$videoButton = New-Object System.Windows.Forms.Button
$videoButton.Text = "Video"
$videoButton.Location = New-Object System.Drawing.Point(150, 60)
$videoButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$popup.Controls.Add($videoButton)

$popup.AcceptButton = $audioButton
$popup.CancelButton = $videoButton

$result = $popup.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $format = "mp3"
    $formatArg = "-x --audio-format mp3"
} elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    $format = "mp4"
    $formatArg = "-f best"
} else {
    Write-Host "No format selected. Exiting..."
    exit
}

Write-Host "Selected format: $format"
Write-Host "Downloading playlist to: $outputDir"

# Change to output directory
Set-Location $outputDir

# Execute yt-dlp to download the playlist
.\yt-dlp.exe $formatArg -o "%(playlist_index)s - %(title)s.%(ext)s" $playlistUrl

Write-Host "Download completed!"
